//
//  AppDelegate.h
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 1/30/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RevMobAds/RevMobAds.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, RevMobAdsDelegate>


@property (strong, nonatomic) RevMobFullscreen* fullScreen;
@property (strong, nonatomic) UIWindow *window;

@end
