//
//  BrowserViewController.h
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/16/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

#import "DownloadsViewController.h"

@interface BrowserViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (assign) BOOL showingConfirmView;//if showing browser web view shoul not start loading

- (void)loadPage:(NSURLRequest *)req;
- (void)set_mDownloadProgressValue:(float)value;

@end
