//
//  AppDelegate.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 1/30/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "AppDelegate.h"

#import "Locker.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SHOWADDS"]) {
        NSLog(@"ADDS YES");
    }else{
        NSLog(@"ADDS NO");
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"appLocked"]){
        Locker *l = [[[Locker alloc] initWithNibName:@"Locker" bundle:nil] autorelease];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dotLocked"]) {
            [(UINavigationController *)self.window.rootViewController pushViewController:l animated:NO];
        }else{
            l.type = YES;
            [(UINavigationController *)self.window.rootViewController pushViewController:l animated:NO];
        }
        
        
    }
    
    [RevMobAds startSessionWithAppID:@"5177b0b539899962f200004b"];
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"appLocked"]){
        Locker *l = [[[Locker alloc] initWithNibName:@"Locker" bundle:nil] autorelease];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dotLocked"]) {
            [(UINavigationController *)self.window.rootViewController pushViewController:l animated:NO];
        }else{
            l.type = YES;
            [(UINavigationController *)self.window.rootViewController pushViewController:l animated:NO];
        }
        
        
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    self.fullScreen = [[RevMobAds session] fullscreen];
    self.fullScreen.delegate=self;
    [self.fullScreen loadAd];
    [self.fullScreen showAd];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    return YES;
}


//MARK: RevMob required delegate methods

- (void) revmobAdDidFailWithError:(NSError *)error {
    NSLog(@"[Rev mob]   app did failed with error: %@",error);
}

- (void) revmobAdDidReceive {
}

- (void) revmobAdDisplayed {
    
}

- (void) revmobUserClickedInTheAd {
}

- (void) revmobUserClosedTheAd {
    
//    //   _freeView : some viewController
//    
//    self.freeView.view.frame = [UIScreen mainScreen].bounds;
//    [self.window addSubview:self.freeView.view];
}

- (void) installDidFail {
    
}

-(void) installDidReceive {
}

@end
