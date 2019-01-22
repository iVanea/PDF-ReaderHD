//
//  BookmarksViewController.h
//  newPDFReaderUniv
//
//  Created by Jora Kalorifer on 17.12.12.
//  Copyright (c) 2012 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrowserViewController;

@interface BookmarksViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,assign) BrowserViewController *parentVC;

@end
