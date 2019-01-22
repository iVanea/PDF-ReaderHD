//
//  DownloadsViewController.h
//  VideoDownloader
//
//  Created by Jora Kalorifer on 8/28/12.
//  Copyright (c) 2012 SviatajaDjigurda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuickLook/QuickLook.h>

#import "DownloadManager.h"

@class BrowserViewController;

@interface DownloadsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DownloadManagerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>
{
    
    IBOutlet UITableView *downloadsTable;
    
    
}

@property (nonatomic, retain) IBOutlet UITableViewCell *downloadCell;
@property (nonatomic) BOOL renameFileAfterDownload;
@property (nonatomic, assign) id parentVC;

- (IBAction)startTest:(UIButton *)sender;
- (void)downloadURLAbsolutePath:(NSString *)url;
- (IBAction)pauseDownload:(UIButton *)sender;

+ (DownloadsViewController *)defaultDVC;

@end
