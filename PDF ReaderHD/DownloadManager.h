//
//  DownloadManager.h
//  VideoDownloader
//
//  Created by Jora Kalorifer on 8/28/12.
//  Copyright (c) 2012 SviatajaDjigurda. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - ASynkConnection interface
typedef void (^completeBlock) (id connection);
typedef void (^errorBlock) (NSError *error);
typedef void (^progressBlock) (float progress);
typedef void (^modifyRequestBlock) (NSMutableURLRequest *request);

enum{
    k_downloadStateInitializing,
    k_downloadStateConnected,
    k_downloadStateActive,
    k_downloadStatePaused,
    k_downloadStateFinished,
    k_downloadStateError
};

@interface ASynkConnection : NSURLConnection
{
@private
	NSMutableData *dataReceived;
	
	errorBlock _errorBlock;
    completeBlock _completeBlock;
    progressBlock _progressBlock;
    
    NSDate *now;
}

@property (readonly, getter = isFinished) BOOL finished;


@property (readonly, copy) NSString *filePath;
@property (nonatomic, retain) NSFileHandle *fileHandle;

@property (readonly, retain) NSString *stringURLRequest;
@property (readonly, getter = isPaused) BOOL pauseOperation;

@property (readonly) float              progressValue;
@property (readonly) float				estimatedTime;
@property (readonly) long long          bytesReceived;
@property (readonly) long long			expectedBytes;
@property (readonly) float              connectionSpeed;
@property (readonly) char               downloadState;
 


@property (readonly, nonatomic) NSString *suggestedFileName;

+ (id)request:(NSString *)requestUrl
     filePath:(NSString *)filePath
completeBlock:(completeBlock)completeBlock
   errorBlock:(errorBlock)errorBlock
progressBlock:(progressBlock)progressBlock;


- (void)pause;
- (void) resume;

@end



@protocol DownloadManagerDelegate <NSObject>

@optional

- (void)downloadsUpdated;
- (void)downloadFinished:(ASynkConnection *)aConnection;
- (void)allDownloadsFinished;

@end


@interface DownloadManager : NSObject
{
    
}
@property (nonatomic,assign) id <DownloadManagerDelegate> delegate;
@property (readonly, retain) NSMutableArray *downloads;

+(DownloadManager *)sharedManager;
- (void)addNewDownloadFromURL:(NSString *)url toFile:(NSString *)filePath;
- (void)pauseConnectionAtIndex:(NSUInteger)index;
- (void)removeConnection:(ASynkConnection *)aConnection;
@end

