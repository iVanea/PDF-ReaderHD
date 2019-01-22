//
//  ViewController.h
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 1/30/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

#import <QuickLook/QuickLook.h>

#import <RevMobAds/RevMobAds.h>

#import "DirectoryWatcher.h"

#import "CellWithTable.h"



@interface MainInterface : UIViewController     <   UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    QLPreviewControllerDelegate,
                                                    QLPreviewControllerDataSource,
                                                    DirectoryWatcherDelegate,
//                                                    SCMenuViewDelegate,
                                                    UIAlertViewDelegate,
                                                    UITextFieldDelegate,
                                                    CellWithTableDelegate,
                                                    RevMobAdsDelegate
                                                >

@end
