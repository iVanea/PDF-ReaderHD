//
//  DownloadManager.m
//  VideoDownloader
//
//  Created by Jora Kalorifer on 8/28/12.
//  Copyright (c) 2012 SviatajaDjigurda. All rights reserved.
//

#import "DownloadManager.h"

#pragma mark - DownloadManager interface
@interface DownloadManager ()
{
    //NSMutableArray *downloads;
    NSTimer *timer;
}
- (id)initManager;
@end
#pragma mark - DownloadManager implementation
@implementation DownloadManager


#pragma mark - Singleton initialization
- (id)initManager
{
    if (self = [super init]) {
        _downloads = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

+(DownloadManager *)sharedManager
{
    static DownloadManager *_defaultManager = nil;
    
    if (_defaultManager != nil)
        return _defaultManager;
    
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      _defaultManager = [[DownloadManager alloc] initManager];
                  });
    
    return _defaultManager;
}

#if !__has_feature(objc_arc)

- (id) retain
{
    return self;
}

- (oneway void) release
{
    // Does nothing here.
}

- (id) autorelease
{
    return self;
}

- (NSUInteger) retainCount
{
    return INT32_MAX;
}

#endif

#pragma mark - Downloads Managment

//add new download

- (void)addNewDownloadFromURL:(NSString *)url toFile:(NSString *)filePath
{
    if (_downloads == nil) {
        _downloads = [[NSMutableArray alloc] init];
    }
    [_downloads addObject:[ASynkConnection request:url
                                          filePath:filePath
                                     completeBlock:^(id connection) {
                                         [self connectionFinished:(ASynkConnection *)connection];
                                     }
                                        errorBlock:^(NSError *error) {
                                            
                                        }
                                     progressBlock:^(float progress) {
                                         [self update];
                                     }]];
    
    NSLog(@"%@",_downloads.description);

    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(update) userInfo:nil repeats:YES];
    }
    
    [self update];
}

//update download progress

- (void)update
{
    
    
    if (_downloads.count == 0) {
        
        [timer invalidate];
        timer = nil;
        
        if ([_delegate respondsToSelector:@selector(downloadsUpdated)]) {
            
            [_delegate downloadsUpdated];
            if ([_delegate respondsToSelector:@selector(allDownloadsFinished)]) {
                [_delegate allDownloadsFinished];
            }
        }
        
        return;
    }
    if ([_delegate respondsToSelector:@selector(downloadsUpdated)]) {
        
        [_delegate downloadsUpdated];
    }
}

- (void)connectionFinished:(ASynkConnection *)connection
{
    //remove download from array
    
    if ([_delegate respondsToSelector:@selector(downloadFinished:)]) {
        [_delegate downloadFinished:connection];
        
    }
    
    
}



- (void)pauseConnectionAtIndex:(NSUInteger)index
{
    [[_downloads objectAtIndex:index] pause];
    
}

- (void)removeConnection:(ASynkConnection *)aConnection
{
    [_downloads removeObject:aConnection];
}



@end


#pragma mark - ASyncConnection implementation

@implementation ASynkConnection



- (id)initWithRequest:(NSString *)requestUrl
             filePath:(NSString *)filePath
        modifyRequest:(modifyRequestBlock)modifyRequestBlock
        completeBlock:(completeBlock)completeBlock
           errorBlock:(errorBlock)errorBlock
             progress:(progressBlock)progressBlock {
    
    _filePath = [[NSString stringWithString:filePath] copy];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
    }
    
    _fileHandle = [[NSFileHandle fileHandleForWritingAtPath:_filePath] retain];
    
    _stringURLRequest = [[NSString stringWithString:requestUrl] copy];
    
	NSURL *url = [NSURL URLWithString:requestUrl];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //[request addValue: [NSString stringWithFormat: @"bytes=%d", 0 ] forHTTPHeaderField: @"Range"];
    modifyRequestBlock(request);
    
	if ((self = [super initWithRequest:request delegate:self startImmediately:NO])) {
		//dataReceived = [[NSMutableData alloc] init];
        _pauseOperation = NO;
		_completeBlock = [completeBlock copy];
		_errorBlock = [errorBlock copy];
        _progressBlock = [progressBlock copy];
        
        _bytesReceived = _progressValue = _estimatedTime = _connectionSpeed = 0;
        
        _downloadState = k_downloadStateInitializing;
 

        
        [self start];
	}
    
	return self;
}

+ (id)request:(NSString *)requestUrl
     filePath:(NSString *)filePath
completeBlock:(completeBlock)completeBlock
   errorBlock:(errorBlock)errorBlock
progressBlock:(progressBlock)progressBlock{
	return [[[self alloc] initWithRequest:requestUrl
                                 filePath:filePath
                            modifyRequest:^(NSMutableURLRequest *r) {}
                            completeBlock:completeBlock
                               errorBlock:errorBlock
                                 progress:progressBlock] autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    
    
    
	NSHTTPURLResponse *r = (NSHTTPURLResponse*)response;
	NSDictionary *headers = [r allHeaderFields];
	if (headers){
		if ([headers objectForKey: @"Content-Range"]) {
//			NSString *contentRange = [headers objectForKey: @"Content-Range"];
//			NSRange range = [contentRange rangeOfString: @"/"];
//			NSString *totalBytesCount = [contentRange substringFromIndex: range.location + 1];
//			_expectedBytes = [totalBytesCount floatValue];
		} else if ([headers objectForKey: @"Content-Length"]) {
			_expectedBytes = [[headers objectForKey: @"Content-Length"] floatValue];
		} else _expectedBytes = -1;
        
		if ([@"Identity" isEqualToString: [headers objectForKey: @"Transfer-Encoding"]]) {
			_expectedBytes = _bytesReceived;
		}
	}
    if (response.suggestedFilename) {
        
        _suggestedFileName = [[NSString stringWithString:response.suggestedFilename] copy];
        
    }
    if (_fileHandle && (self.downloadState == k_downloadStateInitializing)) {
        [_fileHandle truncateFileAtOffset:0];
    }
    if (now) {
        [now release];
    }
    now = [[NSDate date] retain];
    
    _downloadState = k_downloadStateConnected;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (!_pauseOperation) {
        
        if (_downloadState != k_downloadStateActive) {
            _downloadState = k_downloadStateActive;
        }
        
        if (_fileHandle) {
            [_fileHandle seekToEndOfFile];
            [_fileHandle writeData:data];
        }
        
        
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
        NSString *fileSize = [fileAttributes objectForKey:NSFileSize];
        _bytesReceived = [fileSize longLongValue];
        
        NSTimeInterval elapsedTime = [now timeIntervalSinceNow];
        //NSLog(@"времени прошло : %f сек",-elapsedTime);
        
        //Te = (MAX - C)*(Tp/C)
        _estimatedTime = (_expectedBytes - _bytesReceived) * (-elapsedTime/_bytesReceived);
        //NSLog(@"осталось времени : %f сек", _estimatedTime);
        _connectionSpeed = _bytesReceived/-elapsedTime;
        //NSLog(@"скорость : %f Байт/сек",_connectionSpeed);
        
        if(_expectedBytes != NSURLResponseUnknownLength) {
            _progressValue = ((_bytesReceived/(float)_expectedBytes)*100.0)/100.0;
            //_progressBlock(_progressValue);
        }
    } else {
        [self cancel];
    }
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
	_completeBlock(self);
    _downloadState =  k_downloadStateFinished;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Whooops , Something went wrong\nNSURLConnection Error: %@",error);
    _downloadState =  k_downloadStateError;
    _pauseOperation =  YES;
	_errorBlock(error);
}


- (void) pause {
    
    if (_pauseOperation) {
        [self resume];
        return;
    }
    
    _downloadState =  k_downloadStatePaused;
	_pauseOperation = YES;
    _progressBlock(_progressValue);
}

- (void) resume {
    
	_pauseOperation = NO;
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.stringURLRequest]];
	[request addValue:[NSString stringWithFormat: @"bytes=%llu-", _bytesReceived ] forHTTPHeaderField: @"Range"];
    
    self = (ASynkConnection*)[ASynkConnection connectionWithRequest:request delegate:self];
	
}

- (void) dealloc {
    
    [now release];
    
    [dataReceived release];
    
    [_stringURLRequest release];
    
    [_progressBlock release];
	[_completeBlock release];
	[_errorBlock release];
    
	[super dealloc];
}

@end

