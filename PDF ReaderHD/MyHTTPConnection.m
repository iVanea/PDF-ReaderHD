//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import "MyHTTPConnection.h"
#import "HTTPServer.h"
#import "HTTPResponse.h"
#import "AsyncSocket.h"

@interface MyHTTPConnection()
{
    UIViewController *topVC;
    NSString *filename_;
}

@end

@implementation MyHTTPConnection

/**
 * Returns whether or not the requested resource is browseable.
**/
- (BOOL)isBrowseable:(NSString *)path
{
	// Override me to provide custom configuration...
	// You can configure it for the entire server, or based on the current request
	
	return YES;
}


/**
 * This method creates a html browseable page.
 * Customize to fit your needs
**/
- (NSString *)createBrowseableIndex:(NSString *)path
{
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head>"];
	[outdata appendFormat:@"<title>Files from %@</title>", server.name];
    [outdata appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />"];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>Files from %@</h1>", server.name];
    [outdata appendString:@"<bq>The following files are hosted live from the iPhone's Docs folder.</bq>"];
    [outdata appendString:@"<p>"];
	[outdata appendFormat:@"<a href=\"..\">..</a><br />\n"];
    for (NSString *fname in array)
    {
        //NSDictionary *fileDict = [[NSFileManager defaultManager] fileAttributesAtPath:[path stringByAppendingPathComponent:fname] traverseLink:NO];
		NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:fname] error:nil];
		//NSLog(@"fileDict: %@", fileDict);
        NSString *modDate = [[fileDict objectForKey:NSFileModificationDate] description];
		if ([[fileDict objectForKey:NSFileType] isEqualToString: @"NSFileTypeDirectory"]) fname = [fname stringByAppendingString:@"/"];
		[outdata appendFormat:@"<a href=\"%@\">%@</a>		(%8.1f Kb, %@)<br />\n", fname, fname, [[fileDict objectForKey:NSFileSize] floatValue] / 1024, modDate];
    }
    [outdata appendString:@"</p>"];
	
	if ([self supportsPOST:path withSize:0])
	{
		[outdata appendString:@"<form action=\"\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\">"];
		[outdata appendString:@"<label>upload file"];
		[outdata appendString:@"<input type=\"file\" name=\"file\" id=\"file\" onchange=javascript:document.getElementById(\"button\").disabled=!document.getElementById(\"button\").disabled />"];
		[outdata appendString:@"</label>"];
		[outdata appendString:@"<label>"];
		[outdata appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Submit\" disabled=\"true\"/>"];
		[outdata appendString:@"</label>"];
		[outdata appendString:@"</form>"];
	}
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
}


- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)relativePath
{
	if ([@"POST" isEqualToString:method])
	{
		return YES;
	}
    
	return [super supportsMethod:method atPath:relativePath];
}


/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
**/
- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength
{
//	NSLog(@"POST:%@", path);
	
	dataStartIndex = 0;
	multipartData = [[NSMutableArray alloc] initWithCapacity:1];
	postHeaderOK = FALSE;
	
    
	return YES;
}



/**
 * This method is called to get a response for a request.
 * You may return any object that adopts the HTTPResponse protocol.
 * The HTTPServer comes with two such classes: HTTPFileResponse and HTTPDataResponse.
 * HTTPFileResponse is a wrapper for an NSFileHandle object, and is the preferred way to send a file response.
 * HTTPDataResopnse is a wrapper for an NSData object, and may be used to send a custom response.
**/
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    	
	if (requestContentLength > 0)  // Process POST data
	{
		
		if (multipartData == nil) {
            multipartData = [[NSMutableArray alloc] initWithCapacity:1];
        }
		if ([multipartData count] < 2) return nil;
		
		NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes]
													  length:[[multipartData objectAtIndex:1] length]
													encoding:NSUTF8StringEncoding];
		
		NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
		postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
		postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];

		
		
        UInt16 separatorBytes = 0x0A0D;
        NSMutableData* separatorData = [NSMutableData dataWithBytes:&separatorBytes length:2];
        [separatorData appendData:[multipartData objectAtIndex:0]];
        int l = [separatorData length];
        int count = 2;	//number of times the separator shows up at the end of file data
        
        NSFileHandle* dataToTrim = [multipartData lastObject];
        
        
        for (unsigned long long i = [dataToTrim offsetInFile] - l; i > 0; i--)
        {
            [dataToTrim seekToFileOffset:i];
            if ([[dataToTrim readDataOfLength:l] isEqualToData:separatorData])
            {
                [dataToTrim truncateFileAtOffset:i];
                i -= l;
                if (--count == 0) break;
            }
        }
        
		
		[postInfo release];
		[multipartData release];
        [filename_ release],filename_ = nil;
		requestContentLength = 0;
        [[topVC.view viewWithTag:10101] removeFromSuperview];
		
	}
	
	NSString *filePath = [self filePathForURI:path];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		return [[[HTTPFileResponse alloc] initWithFilePath:filePath] autorelease];
	}
	else
	{
		NSString *folder = [path isEqualToString:@"/"] ? [[server documentRoot] path] : [NSString stringWithFormat: @"%@%@", [[server documentRoot] path], path];

		if ([self isBrowseable:folder])
		{
			//NSLog(@"folder: %@", folder);
			NSData *browseData = [[self createBrowseableIndex:folder] dataUsingEncoding:NSUTF8StringEncoding];
            
			return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
		}
	}
	
	return nil;
}

-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0.0f;
    uint64_t totalFreeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }  
    
    return totalFreeSpace;
}


/**
 * This method is called to handle data read from a POST.
 * The given data is part of the POST body.
**/
- (void)processDataChunk:(NSData *)postDataChunk
{
	// Override me to do something useful with a POST.
	// If the post is small, such as a simple form, you may want to simply append the data to the request.
	// If the post is big, such as a file upload, you may want to store the file to disk.
	// 
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	
	static BOOL diskSpaceOK = YES;
    
    static unsigned long long  contLen = 0;
    static unsigned long long  dataRec = 0;
    
    
    
	if (!postHeaderOK)
	{
        diskSpaceOK = YES;
        contLen = 0;
        dataRec = 0;
        topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        UIView *vvv = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
        vvv.backgroundColor = [UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:0.85f];
        UIProgressView *pv = [[[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 35)] autorelease];
        pv.progressTintColor = [UIColor greenColor];
        [vvv addSubview:pv];
        pv.center = vvv.center;
        pv.tag = 11011;
        
        vvv.tag = 10101;
        [topVC.view addSubview:vvv];
        
		UInt16 separatorBytes = 0x0A0D;
		NSData* separatorData = [NSData dataWithBytes:&separatorBytes length:2];
		
		int l = [separatorData length];
        
        NSData *requestData = [(NSData *)CFHTTPMessageCopySerializedMessage(request) autorelease];
        
        NSString *requestStr = [[[NSString alloc] initWithData:requestData encoding:NSASCIIStringEncoding] autorelease];
        

        NSArray *arr = [requestStr componentsSeparatedByString:@"\n"];
        
        
        for (int i = 0; i < [arr count]; i++) {
            NSString *str = [arr objectAtIndex:i];

            if ([str rangeOfString:@"Content-Length: "].location != NSNotFound) {
                NSString *s = [str stringByReplacingOccurrencesOfString:@"Content-Length: " withString:@""];
                contLen = [s integerValue];
                
            }
        }
        
        
        unsigned long long freeSpace = [self getFreeDiskspace];
        
        if (contLen > freeSpace) {
            NSLog(@"Not enough disk space");
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Not enough disk space"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                                  otherButtonTitles: nil] autorelease];
            [alert show];
            
            [vvv removeFromSuperview];
            postHeaderOK = YES;
            diskSpaceOK = NO;
            return;
        }

		for (int i = 0; i < [postDataChunk length] - l; i++)
		{
			NSRange searchRange = {i, l};

			if ([[postDataChunk subdataWithRange:searchRange] isEqualToData:separatorData])
			{
				NSRange newDataRange = {dataStartIndex, i - dataStartIndex};
				dataStartIndex = i + l;
				i += l - 1;
				NSData *newData = [postDataChunk subdataWithRange:newDataRange];

				if ([newData length])
				{
					[multipartData addObject:newData];
                    
				}
				else
				{
					postHeaderOK = TRUE;
					
					NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes] length:[[multipartData objectAtIndex:1] length] encoding:NSUTF8StringEncoding];
                    
                    
					NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
                    
                    
                    if ([postInfoComponents count]==1) {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"File Transfer Faled\nPlease Try Again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [[topVC.view viewWithTag:10101] removeFromSuperview];
                        [alert show];
                        break;
                    }
                    
					postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
					postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
					NSString* filename = [[[server documentRoot] path] stringByAppendingPathComponent:[postInfoComponents lastObject]];

                    //make sure the file is created
                    NSFileManager *defMgr = [NSFileManager defaultManager];
                    NSArray *contents = [defMgr contentsOfDirectoryAtPath:[[server documentRoot] path] error:nil];
                    
                    NSString *ext = filename.pathExtension;
                    NSString *fn  = [[filename lastPathComponent] stringByDeletingPathExtension];
                    
                    
                    int counter = 1;
                    if ([contents containsObject:[fn stringByAppendingPathExtension:ext]]) {
                        fn = [fn stringByAppendingString:@"-1"];
                        while ([contents containsObject:[fn stringByAppendingPathExtension:ext]]) {
                            
                            fn = [fn stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"-%d",counter] withString:[NSString stringWithFormat:@"-%d",++counter]];
                            
                        }
                    }
                    
                    
                    
                    
					NSRange fileDataRange = {dataStartIndex, [postDataChunk length] - dataStartIndex};
					
					[defMgr createFileAtPath:[[[server documentRoot] path] stringByAppendingPathComponent:[fn stringByAppendingPathExtension:ext]] contents:[postDataChunk subdataWithRange:fileDataRange] attributes:nil];
                    contents = [defMgr contentsOfDirectoryAtPath:[[server documentRoot] path] error:nil];
                    
					NSFileHandle *file = [[NSFileHandle fileHandleForUpdatingAtPath:[[[server documentRoot] path] stringByAppendingPathComponent:[fn stringByAppendingPathExtension:ext]]] retain];

                    
					if (file)
					{
						[file seekToEndOfFile];
						[multipartData addObject:file];
                        if (!filename_) {
                            filename_ = [[NSString alloc] initWithString:[fn stringByAppendingPathExtension:ext]];
                        }
					}
                    
					bookForDB = [[[[server documentRoot] path] stringByAppendingPathComponent:[fn stringByAppendingPathExtension:ext]] retain];
					[postInfo release];
					
					break;
				}
			}
		}
	}
	else
	{
        
        if (!diskSpaceOK) {
            return;
        }
        
		[(NSFileHandle*)[multipartData lastObject] writeData:postDataChunk];
        
        if (contLen != 0) {
            float progrs =  (float)dataRec / (float)contLen;
            if (!(UIProgressView *)[[topVC.view viewWithTag:10101] viewWithTag:11011]) {
                UIProgressView *pv = [[[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 35)] autorelease];
                pv.progressTintColor = [UIColor greenColor];
                pv.tag = 11011;
                [[topVC.view viewWithTag:10101] addSubview:pv];
            }
            [(UIProgressView *)[[topVC.view viewWithTag:10101] viewWithTag:11011] setProgress:progrs];
        }
	}
    
    dataRec+=[postDataChunk length];
    
    if (dataRec == contLen) {
        [[topVC.view viewWithTag:10101] removeFromSuperview];
    }
}


- (void)die
{
    
    if (filename_) {
        [[NSFileManager defaultManager] removeItemAtPath:[[[server documentRoot] path] stringByAppendingPathComponent:filename_] error:nil];
        [filename_ release],filename_ = nil;
    }
    
    [multipartData release];
    
    [[topVC.view viewWithTag:10101] removeFromSuperview];
    
    
}



@end