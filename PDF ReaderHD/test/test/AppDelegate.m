//
//  AppDelegate.m
//  test
//
//  Created by Jora Kalorifer on 2/16/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

//- (NSString*) mimeTypeForFileAtPath: (NSString *) path {
//    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        return nil;
//    }
//    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
//    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
//    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], NULL);
//    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
//    CFRelease(UTI);
//    if (!mimeType) {
//        return @"application/octet-stream";
//    }
//    return [NSMakeCollectable((NSString *)mimeType) autorelease];
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    NSError *e = nil;
//    
//    NSString *path = [[NSBundle  mainBundle] pathForResource:@"zel" ofType:@"txt"];
//    
//    
//    NSLog(@"%@",[self mimeTypeForFileAtPath:path]);
    

    
//    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
//    if (e) {
//        NSLog(@"%@",e.description);
//        [e release],e = nil;
//    }
//    
//    NSFileManager *fm = [NSFileManager defaultManager];
//    
//    NSDictionary *attr = [fm attributesOfItemAtPath:path error:&e];
//    if (e) {
//        NSLog(@"%@",e.description);
//    }
//    
//    for (NSString *key in attr.allKeys) {
//        NSLog(@"%@",key);
//        NSLog(@"%@",[attr valueForKey:key]);
//    }
    
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
