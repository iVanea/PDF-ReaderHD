//
//  DownloadsViewController.m
//  VideoDownloader
//
//  Created by Jora Kalorifer on 8/28/12.
//  Copyright (c) 2012 SviatajaDjigurda. All rights reserved.
//

#import "DownloadsViewController.h"

#import "BrowserViewController.h"


#define DOCS_DIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define USERDEFAULTS [NSUserDefaults standardUserDefaults]

@interface DownloadsViewController ()
{
    DownloadManager *p_downloadManager;
    
    NSMutableDictionary *recentDownloads;
    
    NSUInteger selectedRowIndex;
    
    NSURL *fileURL;
}

- (IBAction)closeDownloads:(id)sender;
@end

@implementation DownloadsViewController

-(void)closeDownloads:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

+ (DownloadsViewController *)defaultDVC
{
    static DownloadsViewController *dvc;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        dvc = [[DownloadsViewController alloc] customInit];
    });
    return dvc;
}

- (id)customInit
{
    self = [super initWithNibName:@"DownloadsViewController_iPhone" bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Downloads", @"Downloads");
        p_downloadManager = [DownloadManager sharedManager];
        p_downloadManager.delegate = self;
        
        recentDownloads = [[NSMutableDictionary alloc] initWithDictionary:[USERDEFAULTS valueForKey:@"RecentDownloads"]];
        _renameFileAfterDownload = YES;
        if (!recentDownloads) {
            recentDownloads = [[NSMutableDictionary alloc] init];
        }
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Downloads", @"Downloads");
        //        self.tabBarItem.image = [UIImage imageNamed:@"down30x30"];
        //grab an instance of DownloadManager
        p_downloadManager = [DownloadManager sharedManager];
        p_downloadManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [downloadsTable release];
    downloadsTable = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    recentDownloads.dictionary = [USERDEFAULTS valueForKey:@"RecentDownloads"];
    
    if (!recentDownloads) {
        recentDownloads = [[NSMutableDictionary alloc] init];
    }
    
    [downloadsTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    //TODO:MENU ITEMS
    
    
    
    menu.arrowDirection = UIMenuControllerArrowDefault;
}


- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (NSString *)timeStringFromSeconds:(float)sec
{
    float secVal;
    double integral;
    double fractional;
    NSString *retString = nil;
    secVal = sec * 100 / 100;
    
    if (secVal < 60) {
        
        fractional = modf(secVal, &integral);
        retString = [NSString stringWithFormat:@"%.2f s",secVal];
        
    }else if (secVal<360){
        
        int min = (int)secVal / 60;
        int sec = (int)secVal % 60;
        if (sec<10) {
            retString = [NSString stringWithFormat:@"%d:0%d",min,sec];
        }else{
            retString = [NSString stringWithFormat:@"%d:%d",min,sec];
        }
        
    }else{
        int sec = (int)secVal;
        int h = sec / 3600;
        int m = (sec%3600)/60;
        int s = (sec%3600)%60;
        
        NSString *hstr;
        NSString *mstr;
        NSString *sstr;
        if (h<10) {
            hstr = [NSString stringWithFormat:@"0%d",h];
        }else{
            hstr = [NSString stringWithFormat:@"%d",h];
        }
        if (m<10) {
            mstr = [NSString stringWithFormat:@"0%d",m];
        }else{
            mstr = [NSString stringWithFormat:@"%d",m];
        }
        if (s<10) {
            sstr = [NSString stringWithFormat:@"0%d",s];
        }else{
            sstr = [NSString stringWithFormat:@"%d",s];
        }
        
        retString = [NSString stringWithFormat:@"%@:%@:%@",hstr,mstr,sstr];
    }
    
    return retString;
}

- (NSString *)multipleOfBytesStringFromBytes:(long long)bytes
{
    NSString *retString = nil;
    if (bytes < 1024) {
        retString = @"B";
        
    }else if (bytes < 1048576){
        retString = @"KB";
        
    }else if (bytes < 1073741824){
        retString = @"MB";
        
    }else{
        retString = @"GB";
        
    }
    
    return retString;
}

- (double)doubleFromBytes:(long long)bytes
{
    double retVal = 0;
    if (bytes < 1024) {
        retVal = (double)bytes;
        
    }else if (bytes < 1048576){
        retVal = (bytes / 1024)*100 / 100;
        
    }else if (bytes < 1073741824){
        retVal = (bytes / 1048576)*100 / 100;
        
    }else{
        retVal = (bytes / 1073741824)*100 / 100;
        
    }
    
    return retVal;
}

#pragma mark - DownloadManagerDelegate

- (void)downloadsUpdated
{
    
    [downloadsTable reloadData];
    
    //    [(BrowserViewController *)_parentVC needToAnimateDownloadsButton:YES];
    //
    [(BrowserViewController *)_parentVC set_mDownloadProgressValue:[(ASynkConnection *)p_downloadManager.downloads.lastObject progressValue]];
}


- (void)downloadFinished:(ASynkConnection *)aConnection
{
    
    @try {
        //    NSLog(@"%@",aConnection.description);
        //    NSLog(@"%@",aConnection.suggestedFileName);
        
        NSString *nfname;
        
        if (_renameFileAfterDownload) {
            
            NSString *newPath = [[aConnection.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:aConnection.suggestedFileName];
            NSFileManager *fm = [NSFileManager defaultManager];
            NSLog(@"aConnection.fpath:%@",aConnection.filePath);
            if ([[fm contentsOfDirectoryAtPath:DOCS_DIR error:nil] containsObject:aConnection.suggestedFileName]) {
                NSLog(@"Such file exists in documents");
                nfname = [NSString stringWithString:aConnection.suggestedFileName];
                int count = 1;
                do {
                    nfname = [NSString stringWithFormat:@"%@%d.%@",[aConnection.suggestedFileName stringByDeletingPathExtension],count,[aConnection.suggestedFileName pathExtension]];
                    NSLog(@"nfname:%@",nfname);
                    count++;
                } while ([[fm contentsOfDirectoryAtPath:[aConnection.filePath stringByDeletingLastPathComponent] error:nil] containsObject:nfname]);
                [fm moveItemAtPath:aConnection.filePath toPath:[DOCS_DIR stringByAppendingPathComponent:nfname] error:nil];
            }else{
                NSLog(@"MOVE ITEM");
                
                NSLog(@"newPath :%@",newPath);
                NSLog(@"newPath.byReplacing :%@",[newPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                
                [fm moveItemAtPath:aConnection.filePath toPath:newPath error:nil];
                nfname = [newPath lastPathComponent];
            }
            
        }else{
            
            NSString *newPath = [[aConnection.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[[aConnection.filePath lastPathComponent] stringByAppendingPathExtension:[aConnection.suggestedFileName pathExtension]]];
            [[NSFileManager defaultManager] moveItemAtPath:aConnection.filePath toPath:newPath error:nil];
            nfname = [newPath lastPathComponent];
        }
        
        [p_downloadManager performSelector:@selector(removeConnection:) withObject:aConnection afterDelay:2.5f];
        
        
        [recentDownloads release],recentDownloads = nil;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[USERDEFAULTS valueForKey:@"RecentDownloads"]];
        //        recentDownloads = [[NSMutableDictionary alloc] initWithDictionary:[USERDEFAULTS valueForKey:@"RecentDownloads"]];
        
        
        [dict setObject:[NSString stringWithString:nfname] forKey:[NSString stringWithString:[[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle] description]]];
        
        [USERDEFAULTS setObject:dict forKey:@"RecentDownloads"];
        
        //    [recentDownloads setValue:[NSString stringWithString:aConnection.suggestedFileName] forKey:[NSString stringWithString:[[NSDate date] description]]];
        recentDownloads = [dict retain];
        [downloadsTable reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"%s\t%d",__PRETTY_FUNCTION__,__LINE__);
        NSLog(@"%@",exception.reason);
    }
    
    
}

- (void)allDownloadsFinished
{
    //    [(BrowserViewController *)_parentVC needToAnimateDownloadsButton:NO];
    //    [(BrowserViewController *)_parentVC set_mDownloadProgressValue:0.0f];
}

#pragma mark - UITableViewDelegate / DataSource

- (void)accessoryBtnAction:(UIButton *)sender
{
    [(ASynkConnection *)[p_downloadManager.downloads objectAtIndex:sender.tag] pause];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"recdowncount =%d",recentDownloads.allKeys.count);
    if (recentDownloads.allKeys.count == 0) {
        
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return recentDownloads.allKeys.count;
    }
    return p_downloadManager.downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    static NSString *cellID1 = @"cellID1";
    
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"downloads_cell" owner:self options:nil];
            cell = _downloadCell;
            self.downloadCell = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [(UIButton *)cell.accessoryView addTarget:self action:@selector(pauseDownload:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        //cell.textLabel.text = [NSString stringWithFormat:@"%.2f",[(ASynkConnection *)[p_downloadManager.downloads objectAtIndex:indexPath.row] progressValue]];
        cell.accessoryView.tag = indexPath.row;
        
        ASynkConnection *async = [p_downloadManager.downloads objectAtIndex:indexPath.row];
        
        switch ([async downloadState]) {
                
            case k_downloadStateInitializing:
                [(UIButton *)cell.accessoryView setTitle:@"🚥" forState:UIControlStateNormal];
                break;
            case k_downloadStateConnected:
                [(UIButton *)cell.accessoryView setTitle:@"🆗" forState:UIControlStateNormal];
                break;
            case k_downloadStateActive:
                [(UIButton *)cell.accessoryView setTitle:@"⬇" forState:UIControlStateNormal];
                break;
            case k_downloadStatePaused:
                [(UIButton *)cell.accessoryView setTitle:@"▶" forState:UIControlStateNormal];
                break;
            case k_downloadStateFinished:
                [(UIButton *)cell.accessoryView setTitle:@"👍" forState:UIControlStateNormal];
                break;
            case k_downloadStateError:
                [(UIButton *)cell.accessoryView setTitle:@"⚠" forState:UIControlStateNormal];
                break;
        }
        
        UILabel *downloadName = (UILabel *)[cell.backgroundView viewWithTag:10];
        UILabel *downloadProgressInfo = (UILabel *)[cell.backgroundView viewWithTag:11];
        UIProgressView *downloadProgress = (UIProgressView *)[cell.backgroundView viewWithTag:12];
        
        
        if (_renameFileAfterDownload) {
            if (async.suggestedFileName!=NULL) {
                [downloadName setText:async.suggestedFileName];
            }else{
                [downloadName setText:[async.filePath lastPathComponent]];
            }
        }else{
            [downloadName setText:async.filePath.lastPathComponent];
        }
        
        
        
        
        
        [downloadProgressInfo setText:[NSString stringWithFormat:@"%.2f %@/%.2f %@\n%.2f %@/s  ET %@",
                                       [self doubleFromBytes:async.bytesReceived],
                                       [self multipleOfBytesStringFromBytes:async.bytesReceived],
                                       [self doubleFromBytes:async.expectedBytes],
                                       [self multipleOfBytesStringFromBytes:async.expectedBytes],
                                       [self doubleFromBytes:async.connectionSpeed],
                                       [self multipleOfBytesStringFromBytes:async.connectionSpeed],
                                       [self timeStringFromSeconds:async.estimatedTime]]];
        
        [downloadProgress setProgress:async.progressValue];
        
        
        
    }else if (indexPath.section == 1){
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellID1];
        
        if (cell == nil) {
            //            [[NSBundle mainBundle] loadNibNamed:@"downloads_cell" owner:self options:nil];
            //            cell = _downloadCell;
            //            self.downloadCell = nil;
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID1];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            [(UIButton *)cell.accessoryView addTarget:self action:@selector(pauseDownload:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_cell_.png"]];
            cell.backgroundView = back;
            [back release];
            
        }
        [recentDownloads setDictionary:[USERDEFAULTS valueForKey:@"RecentDownloads"]];
        NSArray *sorted = [recentDownloads.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 isKindOfClass:[NSDate class]]) {
                return [obj1 compare:obj2];
            }
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        
        NSLog(@"%@",recentDownloads.description);
        
        cell.textLabel.text = [(NSDate *)[sorted objectAtIndex:indexPath.row] description];
        
        cell.detailTextLabel.text = [recentDownloads valueForKey:cell.textLabel.text];
    }else{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ASynkConnection *asynk = [p_downloadManager.downloads objectAtIndex:indexPath.row];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if ( asynk.downloadState == k_downloadStateActive) {
            menu.menuItems = @[
                               [[UIMenuItem alloc] initWithTitle:@"Pause" action:@selector(menuActionPause)],
                               [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(menuActionCopy)] ,
                               [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuActionDelete)]
                               ];
        }else if (asynk.downloadState == k_downloadStateError || asynk.downloadState == k_downloadStatePaused){
            menu.menuItems = @[
                               [[UIMenuItem alloc] initWithTitle:@"Resume" action:@selector(menuActionResume)],
                               [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(menuActionCopy)] ,
                               [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuActionDelete)]
                               ];
        }
        
        
        
        
        [menu setTargetRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:downloadsTable];
        
        
        [menu setMenuVisible:YES animated:YES];
        
        selectedRowIndex = indexPath.row;
        
        //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if (indexPath.section == 1){
        //TODO:open document + options
        if (fileURL) {
            [fileURL release];
        }
        
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
        fileURL = [[NSURL fileURLWithPath:[docsPath stringByAppendingPathComponent:fileName]] retain];
        
        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        previewController.dataSource = self;
        previewController.delegate = self;
        
        // start previewing the document at the current section index
        
        previewController.currentPreviewItemIndex = 0;
        [previewController.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [previewController.navigationController.toolbar setBarStyle:UIBarStyleBlack];
        [self presentViewController:previewController animated:YES completion:^{
            
            NSLog(@"%@",previewController.view.subviews.description);
        }];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (section == 1) {
        title = @"Recent Downloads";
    }else{
        title = nil;
    }
    return title;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.section == 1) {
            // Delete the row from the data source
            NSLog(@"docs Tab delete");
            
            NSString *bmark = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
            
            
            //                filesViewTopLabel.text = [NSString stringWithFormat:@"%d",filesViewTopLabel.text.integerValue - 1];
            //
            ////                [self fileTypeSelected:nil];
            //                NSLog(@"dilet = %d",fileTypeSelected);
            //                afterDelete = YES;
            //                [self performSelector:@selector(fileTypeSelected:) withObject:[filesView viewWithTag:fileTypeSelected] afterDelay:0.3f];
            
            UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to remove this entry:" message:[bmark stringByAppendingString:@"\t ?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
            [alert show];
        }
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        
        
        NSString *key_ = nil;
        
        for (NSString *key in  recentDownloads.allKeys.objectEnumerator) {
            if ([[recentDownloads objectForKey:key] isEqualToString:[alertView.message stringByReplacingOccurrencesOfString:@"\t ?" withString:@""]]) {
                key_ = key;
            }
        }
        
        [recentDownloads removeObjectForKey:key_];
        
        [downloadsTable reloadData];
        
        [USERDEFAULTS setObject:recentDownloads forKey:@"RecentDownloads"];
        
    }
    
    
}


#pragma mark - Menu Actions
- (void)menuActionPause
{
    [self pauseDownload:nil];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = @[
                       [[UIMenuItem alloc] initWithTitle:@"Resume" action:@selector(menuActionResume)],
                       [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(menuActionCopy)] ,
                       [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuActionDelete)]
                       ];
    [menu update];
}

- (void)menuActionDelete
{
    ASynkConnection *async = [p_downloadManager.downloads objectAtIndex:selectedRowIndex];
    NSString *pStr = [NSString stringWithString:async.filePath];
    [async cancel];
    if([[NSFileManager defaultManager] fileExistsAtPath:pStr]){
        [[NSFileManager defaultManager] removeItemAtPath:pStr error:nil];
    }
    [p_downloadManager removeConnection:async];
}

- (void)menuActionResume
{
    [self pauseDownload:nil];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = @[
                       [[UIMenuItem alloc] initWithTitle:@"Pause" action:@selector(menuActionPause)],
                       [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(menuActionCopy)] ,
                       [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuActionDelete)]
                       ];
    [menu update];
}

- (void)menuActionCopy
{
    UITableViewCell *cell = [downloadsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0]];
    [[UIPasteboard generalPasteboard] setString:[(UILabel *)[cell viewWithTag:10] text]];
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(menuActionCopy) ||
        action == @selector(menuActionDelete) ||
        action == @selector(menuActionResume) ||
        action == @selector(menuActionPause)
        )
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - dealloc

- (void)dealloc {
    [downloadsTable release];
    [super dealloc];
}


- (IBAction)startTest:(UIButton *)sender
{
    NSArray *arr = @[ @"http://192.168.1.238/LION.zip",
                      @"http://www.cerritos.edu/charbut/AP151/151%20Endocrine.ppt",
                      @"https://www.plawa.com/download/14187/AP_DV-5000G_147.JPG"
                      ];
    //
    //
    //    NSString *uniqueStr = [NSString stringWithFormat:@"%d",(int)[NSDate timeIntervalSinceReferenceDate]/(arc4random()%2353)];
    //    [p_downloadManager addNewDownloadFromURL:[arr objectAtIndex:0] toFile:[DOCS_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@test1.zip",uniqueStr]]];
    //    //[p_downloadManager addNewDownloadFromURL:[arr objectAtIndex:1] toFile:[DOCS_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@test2.ppt",uniqueStr]]];
    
    //    NSString *randFileName = [self genRandStringLength:8];
    //NSLog(@"%@",randFileName);
    
    [p_downloadManager addNewDownloadFromURL:[arr objectAtIndex:1] toFile:[DOCS_DIR stringByAppendingPathComponent:[self genRandStringLength:8]]];
    
    
}

#pragma mark - Generate random string

-(NSString *) genRandStringLength: (int) len {
    
    
    static const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

- (void)downloadURLAbsolutePath:(NSString *)url
{
    @try{
        NSLog(@"%@",url);
        NSString *randFileName = nil;
        
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSArray *contents = [filemgr contentsOfDirectoryAtPath:DOCS_DIR error:nil];
        //    while ([contents containsObject:randFileName]) {
        //        randFileName = [self genRandStringLength:8];
        //    }
        do {
            randFileName = [self genRandStringLength:8];
        } while ([contents containsObject:randFileName]);
        
        _renameFileAfterDownload = YES;
        
        [p_downloadManager addNewDownloadFromURL:url toFile:[DOCS_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.file",randFileName]]];
    }@catch (NSException *e){
        NSLog(@"%@",[e reason]);
    }
}

- (IBAction)pauseDownload:(UIButton *)sender
{
    if (sender == nil) {
        [p_downloadManager pauseConnectionAtIndex:selectedRowIndex];
    }else{
        [p_downloadManager pauseConnectionAtIndex:sender.tag];
    }
    
}

#pragma mark - Preview View Controller delegate/datasource


- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

- (int)fileTypeSelected
{
    NSString *ext = fileURL.absoluteString.pathExtension;
    
    NSLog(@"ext = %@", ext);
    
    if ([ext isEqualToString:@".pdf"]) {
        return 1000;
    }
    if ([ext isEqualToString:@".doc"] || [ext isEqualToString:@".docx"]) {
        return 1001;
    }
    if ([ext isEqualToString:@".xls"] || [ext isEqualToString:@".xlsx"]) {
        return 1002;
    }
    if ([ext isEqualToString:@".ppt"] || [ext isEqualToString:@".pptx"]) {
        return 1003;
    }
    if ([ext isEqualToString:@".txt"] || [ext isEqualToString:@".rtf"] || [ext isEqualToString:@".htm"] || [ext isEqualToString:@".html"]) {
        return 1004;
    }
    if ([ext isEqualToString:@".gif"] || [ext isEqualToString:@".png"] || [ext isEqualToString:@".bmp"] || [ext isEqualToString:@".jpg"] || [ext isEqualToString:@".jpeg"]) {
        return 1005;
    }
    if ([ext isEqualToString:@".mp4"] || [ext isEqualToString:@".m4v"] || [ext isEqualToString:@".3gp"] || [ext isEqualToString:@".mov"]) {
        return 1006;
    }
    return 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    UIColor *barColor;
    
    switch (self.fileTypeSelected) {
        case 1000:
            barColor = [UIColor colorWithRed:0.98f green:0.23f blue:0.12f alpha:1.0f];
            break;
        case 1001:
            barColor = [UIColor colorWithRed:0.09f green:0.67f blue:0.97f alpha:1.0f];
            break;
        case 1002:
            barColor = [UIColor colorWithRed:0.44f green:0.65f blue:0.11f alpha:1.0f];
            break;
        case 1003:
            barColor = [UIColor colorWithRed:1.0f green:0.34f blue:0.11f alpha:1.0f];
            break;
        case 1004:
            barColor = [UIColor colorWithRed:0.42f green:0.62f blue:0.69f alpha:1.0f];
            break;
        case 1005:
            barColor = [UIColor colorWithRed:0.95f green:0.20f blue:0.34f alpha:1.0f];
            break;
        case 1006:
            barColor = [UIColor colorWithRed:1.00f green:0.820f blue:0.0f alpha:1.0f];
            break;
        default:
            barColor = [UIColor blackColor];
            break;
            
    }
    
    for (id object in controller.childViewControllers)
    {
        if ([object isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController = object;
            navController.navigationBar.tintColor = barColor;
            navController.toolbar.tintColor = barColor;
        }
    }
    
    return fileURL;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


#pragma mark -

@end
