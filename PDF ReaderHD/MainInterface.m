//
//  ViewController.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 1/30/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "MainInterface.h"



#import "Locker.h"

#import "SetLocker.h"

#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "localhostAddresses.h"

#import "BrowserViewController.h"

#import "PDFDocumentViewController.h"


#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"

#import "NOADDS.h"

enum
{
    k_pdf = 0,
    k_doc,
    k_xls,
    k_ppt,
    k_txt,
    k_img,
    k_vid
};

@interface MainInterface ()
{
    IBOutlet UIView *adWhirlContainer;
    AdWhirlView *_adWhirlView;
    
    
    IBOutlet UITableView *filesTableView;
    IBOutlet UIView *downloadTab;
    IBOutlet UIView *settingsTab;
    
    IBOutlet UIView *bottomLine;
    
    NSMutableArray *selectedFileTypeURLs;
    unsigned selectedFileType;
    
    unsigned selectedCell;
    
    char menuType;
    
    BOOL showsCellWithTable;
    
    NSMutableArray *cellMap;
    
    CellWithTable *_cellWithTable;
    
    NSMutableDictionary *filesCountDictionary;
    
    IBOutlet UISwitch *fileTransferSwitch;
    
    IBOutlet UISwitch *appLockSwitch;
    
    IBOutlet UISwitch *preventSleepModeSwitch;
    
    DirectoryWatcher *dw;
    
    
    //HTTPServer////////////////////////
    
    HTTPServer *httpServer;
    NSDictionary *addresses;
	NSString *ip;
    
    IBOutlet UILabel *ipLabel;
    ////////////////////////////////////
    BrowserViewController *browser;
    
    IBOutlet UIView *renameView;
    
    IBOutlet UITextField *renameTf;
    IBOutlet UIScrollView *helpScrollView;
    
    
    IBOutlet UIView *docHelpView;
    IBOutlet UIImageView *helpImg;
    
    
    IBOutlet UIImageView *docHelpImg;
    IBOutlet UIImageView *downHelpImage;
    IBOutlet UIImageView *settingsHelpImage;
    IBOutlet UIImageView *filesHelpImage;
    
}

- (IBAction)switchTab:(UIButton *)sender;


@end

@implementation MainInterface

- (BOOL)shouldAutorotate
{
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{

    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (showsCellWithTable) {
        [filesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    if ([self.view viewWithTag:1111] == filesTableView) {
        if (showsCellWithTable) {
            CGRect r = docHelpView.frame;
            r.size.height = filesHelpImage.frame.size.height;
            docHelpView.frame = r;
            helpScrollView.contentSize = docHelpView.frame.size;
        }else{
            CGRect r = docHelpView.frame;
            r.size.height = docHelpImg.frame.size.height;
            docHelpView.frame = r;
            helpScrollView.contentSize = docHelpView.frame.size;
        }
    }else if ([self.view viewWithTag:1111] == downloadTab){
        CGRect r = docHelpView.frame;
        r.size.height = downHelpImage.frame.size.height;
        docHelpView.frame = r;
        helpScrollView.contentSize = docHelpView.frame.size;
    }else if ([self.view viewWithTag:1111] == settingsTab){
        CGRect r = docHelpView.frame;
        r.size.height = settingsHelpImage.frame.size.height;
        docHelpView.frame = r;
        helpScrollView.contentSize = docHelpView.frame.size;
    }
    
}

- (void)loadView
{
    [[NSBundle mainBundle] loadNibNamed:@"MainInterface" owner:self options:nil];
}

#pragma mark -

- (CGRect)frameForInterfaceOrientationForView:(UIView *)view
{
    
    BOOL shAdd = YES;
    
    
    
    CGRect retVal = view.frame;
    
    if (shAdd) {
        if (view.tag == 1111) {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                retVal = CGRectMake(11, 132, 1001, 448);
            }else{
                retVal = CGRectMake(11, 132, 745, 704);
            }
        }
    }else{
        if (view.tag == 1111) {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                retVal = CGRectMake(11, 132, 1001, 538);
            }else{
                retVal = CGRectMake(11, 132, 745, 794);
            }
        }
    }
    
    return retVal;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    cellMap = [[NSMutableArray alloc] init];
    
    downloadTab.frame = settingsTab.frame = filesTableView.frame;
    
    selectedCell = -2;
    
    dw = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
    
    [dw setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obsSel) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    browser = [[BrowserViewController alloc] initWithNibName:@"BrowserViewController" bundle:nil];
    
    ipLabel.layer.cornerRadius = 15;
    
//    CGRect r = docHelpView.frame;
//    r.size.height = docHelpImg.frame.size.height;
//    docHelpView.frame = r;
//    helpScrollView.contentSize = docHelpView.frame.size;
    
    BOOL shAdds = YES;
    
    if (shAdds) {
        
//        adWhirlContainer addSubview
        _adWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:(id)self];
        _adWhirlView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                         |UIViewAutoresizingFlexibleRightMargin
                                         |UIViewAutoresizingFlexibleLeftMargin);
        
        [_adWhirlView updateAdWhirlConfig];
        _adWhirlView.frame = adWhirlContainer.bounds;
        _adWhirlView.clipsToBounds = YES;
        
        [adWhirlContainer addSubview:_adWhirlView];
        
    }else{
        
    }
    
}

- (NSString *)adWhirlApplicationKey {
    
    return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)?@"ed7d0db8970a44c79989d57fe34a9ceb":@"43f96c338e3f49839eb3ed967c2bc083";
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)obsSel
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self populateSelectedFileTipeURLsArrayForFileType:k_pdf];
    
    //Set switches
    
    [appLockSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"appLocked"]];
    [preventSleepModeSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"sleepMode"]];
    
//    if (showsCellWithTable) {
//        [filesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (showsCellWithTable) {
        [filesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if (showsCellWithTable) {
        return 8;
    }else{
        return 7;
    }
    
    return (selectedFileTypeURLs.count + 7);
}

- (UIImage *)imageForNumber:(short)number
{
    
    //TODO:Return localized images
    UIImage *img = nil;
    NSString *localeID = @"";
    
    if ([[self prefferedLanguage] isEqualToString:@"ru"]) {
        localeID = @"_ru";
    }
    switch (number) {
        case 0:
            img = [UIImage imageNamed:[@"ipad_pdf" stringByAppendingString:localeID]];
            break;
        case 1:
            img = [UIImage imageNamed:[@"ipad_word" stringByAppendingString:localeID]];
            break;
        case 2:
            img = [UIImage imageNamed:[@"ipad_xls" stringByAppendingString:localeID]];
            break;
        case 3:
            img = [UIImage imageNamed:[@"ipad_ppt" stringByAppendingString:localeID]];
            break;
        case 4:
            img = [UIImage imageNamed:[@"ipad_txt" stringByAppendingString:localeID]];
            break;
        case 5:
            img = [UIImage imageNamed:[@"ipad_photo" stringByAppendingString:localeID]];
            break;
        case 6:
            img = [UIImage imageNamed:[@"ipad_video" stringByAppendingString:localeID]];
            break;
    }
    
    return img;
}

- (NSString *)keyForNumber:(unsigned)number
{
    NSString *key = nil;
    switch (number) {
        case k_pdf:
            key = @"pdf";
            break;
        case k_doc:
            key = @"doc";
            break;
        case k_xls:
            key = @"xls";
            break;
        case k_ppt:
            key = @"ppt";
            break;
        case k_txt:
            key = @"txt";
            break;
        case k_img:
            key = @"img";
            break;
        case k_vid:
            key = @"vid";
            break;
        default:
            break;
    }
    return key;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *cellWT = @"WTCELL";
    
    UITableViewCell *cell;
    
    
    if (showsCellWithTable) {
        
        if (indexPath.row == selectedCell+1) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellWT];
            [(CellWithTable *)cell updateTableViewFrame];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        }
        
        if (!cell) {
            if (indexPath.row == selectedCell+1) {
                cell = [[CellWithTable alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellWT];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                _cellWithTable = (CellWithTable *)cell;
                _cellWithTable.delegate = self;
            }else{
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
                label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:100];
                label.textAlignment = NSTextAlignmentRight;
                label.textColor = [UIColor whiteColor];
                cell.accessoryView = label;
                [label release];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        
        NSNumber *number = [cellMap objectAtIndex:indexPath.row];
        if ([number integerValue] != -1) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[self imageForNumber:number.integerValue]];
            imgView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            cell.backgroundView = imgView;
            cell.tag = number.integerValue;
            

            
            NSString *text = [NSString stringWithFormat:@"%d",[(NSNumber *)[filesCountDictionary valueForKey:[self keyForNumber:cell.tag]] unsignedIntValue]];
            NSLog(@"%@",text);
            [(UILabel *)cell.accessoryView setText:text];
            
            [imgView release];
        }else{
            
            [(CellWithTable *)cell setDataArray:selectedFileTypeURLs];
            [(CellWithTable *)cell setFileTypeSelected:selectedCell];
        }
    
        
    }else{
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 90)];
            label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:85];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentRight;
            label.backgroundColor = [UIColor clearColor];
            cell.accessoryView = label;
//            cell.accessoryView.layer.borderColor = [UIColor greenColor].CGColor;
//            cell.accessoryView.layer.borderWidth = 1;
            [label release];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[self imageForNumber:indexPath.row]];
        imgView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        cell.backgroundView = imgView;
        cell.tag = indexPath.row;
        [imgView release];
        
        
        NSString *text = [NSString stringWithFormat:@"%d",[(NSNumber *)[filesCountDictionary valueForKey:[self keyForNumber:indexPath.row]] unsignedIntValue]];
        
        
        
        [(UILabel *)cell.accessoryView setText:text];
        

    }
    
    
    // Configure the cell...
    
    
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat h = 108;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        h*=1.3333333333;
    }
    if (showsCellWithTable) {
        float cwth = selectedFileTypeURLs.count * 74;
        if (selectedFileTypeURLs.count>0) {
            cwth = filesTableView.frame.size.height - h;
        }else if (selectedFileTypeURLs.count == 0){
            cwth = 74;
        }
        if (indexPath.row == selectedCell+1)
            (h =  cwth);
    }
    return h;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == selectedCell+1) {
        
        return;
    }
    
    if (indexPath.row == selectedCell) {
        
        showsCellWithTable = NO;
        
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedCell+1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        selectedCell = -2;
        
        [filesTableView setScrollEnabled:YES];
        
        return;
    }
    
    short row = 0;
    
    [tableView beginUpdates];
    
    if (showsCellWithTable) {
        
        showsCellWithTable = NO;
        
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedCell+1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (!indexPath.row == 0 && indexPath.row > selectedCell) {
            row = 1;
        }
    
        
    }
    
    
    selectedCell = indexPath.row - row;

    showsCellWithTable = YES;
    
    [cellMap removeAllObjects];
    
    for (int i = 0; i < 8; i++) {
        if (i == selectedCell+1) {
            [cellMap addObject:[NSNumber numberWithInt:-1]];
        }else{
            
            if (i <= selectedCell) {
                [cellMap addObject:[NSNumber numberWithInt:i]];
                continue;
            }
            
            if ((i - selectedCell) > 1) {
                [cellMap addObject:[NSNumber numberWithInt:i-1]];
            }
        }
    }
    
    [self populateSelectedFileTipeURLsArrayForFileType:selectedCell];
    
    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedCell+1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    
    //[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell+1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [tableView setScrollEnabled:NO];
    
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    //[tableView endUpdates];

}

#pragma mark -

- (void)deleteItem:(id)item
{
    if ([selectedFileTypeURLs containsObject:item]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:item error:nil];
        
        [selectedFileTypeURLs removeObject:item];
        
        [_cellWithTable setDataArray:selectedFileTypeURLs];
        [_cellWithTable updateTableViewFrame];
    }

}

- (void)renameItem:(id)item
{
    
    renameView.hidden = NO;
    
    renameView.tag = [selectedFileTypeURLs indexOfObject:item];
    
    renameTf.text = [(NSURL *)[selectedFileTypeURLs objectAtIndex:renameView.tag] lastPathComponent];
    [renameTf becomeFirstResponder];
    // Get current selected range , this example assumes is an insertion point or empty selection
    UITextRange *selectedRange = [renameTf selectedTextRange];
    
    // Calculate the new position, - for left and + for right
    unsigned extLen = renameTf.text.pathExtension.length+1;
    
    [renameTf setSelectedTextRange:[renameTf textRangeFromPosition:renameTf.endOfDocument toPosition:renameTf.endOfDocument]];
    
    UITextPosition *newPosition = [renameTf positionFromPosition:selectedRange.start offset:-extLen];
    
    // Construct a new range using the object that adopts the UITextInput, our textfield
    UITextRange *newRange = [renameTf textRangeFromPosition:newPosition toPosition:renameTf.beginningOfDocument];
    
    // Set new range
    [renameTf setSelectedTextRange:newRange];
    
}

- (IBAction)acceptRename:(UIButton *)sender
{
    if (renameTf.text.length == 0) {
        return;
    }
    NSString *ext = [[selectedFileTypeURLs objectAtIndex: renameView.tag] pathExtension];
    
    NSString *newPath = [[[selectedFileTypeURLs objectAtIndex: renameView.tag] path] stringByDeletingLastPathComponent];
    
    newPath = [newPath stringByAppendingPathComponent:renameTf.text];
    
    if (![newPath.pathExtension isEqualToString:ext]) {
        newPath = [newPath stringByAppendingPathExtension:ext];
    }
    
    NSURL *toUrl = [NSURL fileURLWithPath:newPath];
    
    [[NSFileManager defaultManager] moveItemAtURL:[selectedFileTypeURLs objectAtIndex:renameView.tag] toURL:toUrl error:nil];
    
    [self populateSelectedFileTipeURLsArrayForFileType:selectedCell];
    
    [_cellWithTable setDataArray:selectedFileTypeURLs];
    [_cellWithTable updateTableViewFrame];
    
    renameView.hidden = YES;
    [renameTf resignFirstResponder];
}

- (IBAction)cancelRename:(UIButton *)sender
{
    renameView.hidden = YES;
    [renameTf resignFirstResponder];
}



#pragma mark - QLPreviewControllerDelegate

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return 1;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

#pragma mark -

- (void)updateFilesCountDictionary
{
    
    if (!filesCountDictionary) {
        filesCountDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [filesCountDictionary removeAllObjects];
    
    unsigned counters[7] = {};
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil];
    
    for (NSString *fileName in contents) {
        if ([[fileName.pathExtension lowercaseString]isEqualToString:@"pdf"]) {
            
            counters[k_pdf]++;
        }
        if ([[fileName.pathExtension lowercaseString] isEqualToString:@"doc"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"docx"]) {
            
            counters[k_doc]++;
        }
        if ([[fileName.pathExtension lowercaseString] isEqualToString:@"xls"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"xlsx"]) {
            
            counters[k_xls]++;
        }
        if ([[fileName.pathExtension lowercaseString] isEqualToString:@"ppt"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"pptx"]) {
            
            counters[k_ppt]++;
        }
        if ([[fileName.pathExtension lowercaseString] isEqualToString:@"txt"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"rtf"]
            || [[fileName.pathExtension lowercaseString] isEqualToString:@"html"]) {
            
            counters[k_txt]++;
        }
        
        if ([[fileName.pathExtension lowercaseString] isEqualToString:@"bmp"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"gif"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"jpg"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"jpeg"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"png"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"tiff"]) {
            
            counters[k_img]++;
        }
        
        if ([[fileName.pathExtension lowercaseString] isEqualToString:@"avi"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"3gp"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"m4v"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"mp4"]) {
            
            counters[k_vid]++;
        }
    }
    
    [filesCountDictionary setValue:[NSNumber numberWithUnsignedInt:counters[k_pdf]] forKey:@"pdf"];
    [filesCountDictionary setValue:[NSNumber numberWithUnsignedInt:counters[k_doc]] forKey:@"doc"];
    [filesCountDictionary setValue:[NSNumber numberWithUnsignedInt:counters[k_xls]] forKey:@"xls"];
    [filesCountDictionary setValue:[NSNumber numberWithUnsignedInt:counters[k_ppt]] forKey:@"ppt"];
    [filesCountDictionary setValue:[NSNumber numberWithUnsignedInt:counters[k_txt]] forKey:@"txt"];
    [filesCountDictionary setValue:[NSNumber numberWithUnsignedInt:counters[k_img]] forKey:@"img"];
    [filesCountDictionary setValue:[NSNumber numberWithUnsignedInt:counters[k_vid]] forKey:@"vid"];
    
    
}

- (void)populateSelectedFileTipeURLsArrayForFileType:(unsigned)fileType
{
    
    if (!selectedFileTypeURLs) {
        selectedFileTypeURLs = [[NSMutableArray alloc] init];
    }
    
    [selectedFileTypeURLs removeAllObjects];
    
    NSFileManager *defMgr = [NSFileManager defaultManager];
    
    NSString *appDir = [self applicationDocumentsDirectory];
    NSArray *contents = [defMgr contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil];
    
    contents = [contents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[[[NSFileManager defaultManager] attributesOfItemAtPath:[appDir stringByAppendingPathComponent:obj2] error:nil] valueForKey:NSFileCreationDate] compare:[[[NSFileManager defaultManager] attributesOfItemAtPath:[appDir stringByAppendingPathComponent:obj1] error:nil] valueForKey:NSFileCreationDate]];
        
    }];
    
    [self updateFilesCountDictionary];
    
    switch (fileType) {
        case k_pdf:
            for (NSString *fileName in contents.objectEnumerator) {
                
                if ([[fileName.pathExtension lowercaseString] isEqualToString:@"pdf"]) {
                    
                    [selectedFileTypeURLs addObject:[NSURL fileURLWithPath:[appDir stringByAppendingPathComponent:fileName]]];
                }
            }
            break;
        case k_doc:
            for (NSString *fileName in contents.objectEnumerator) {
                
                if ([[fileName.pathExtension lowercaseString] isEqualToString:@"doc"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"docx"]) {
                    
                    [selectedFileTypeURLs addObject:[NSURL fileURLWithPath:[appDir stringByAppendingPathComponent:fileName]]];
                }
            }
            break;
        case k_xls:
            for (NSString *fileName in contents.objectEnumerator) {
                
                if ([[fileName.pathExtension lowercaseString] isEqualToString:@"xls"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"xlsx"]) {
                    
                    [selectedFileTypeURLs addObject:[NSURL fileURLWithPath:[appDir stringByAppendingPathComponent:fileName]]];
                }
            }
            break;
        case k_ppt:
            for (NSString *fileName in contents.objectEnumerator) {
                
                if ([[fileName.pathExtension lowercaseString] isEqualToString:@"ppt"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"pptx"]) {
                    
                    [selectedFileTypeURLs addObject:[NSURL fileURLWithPath:[appDir stringByAppendingPathComponent:fileName]]];
                }
            }
            break;
        case k_txt:
            for (NSString *fileName in contents.objectEnumerator) {
                
                if ([[fileName.pathExtension lowercaseString] isEqualToString:@"txt"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"rtf"]
                    || [[fileName.pathExtension lowercaseString] isEqualToString:@"html"]) {
                    
                    [selectedFileTypeURLs addObject:[NSURL fileURLWithPath:[appDir stringByAppendingPathComponent:fileName]]];
                }
            }
            break;
        case k_img:
            for (NSString *fileName in contents.objectEnumerator) {
                
                if ([[fileName.pathExtension lowercaseString] isEqualToString:@"bmp"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"gif"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"jpg"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"jpeg"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"png"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"tiff"]) {
                    
                    [selectedFileTypeURLs addObject:[NSURL fileURLWithPath:[appDir stringByAppendingPathComponent:fileName]]];
                }
            }
            break;
        case k_vid:
            for (NSString *fileName in contents.objectEnumerator) {
                
                if ([[fileName.pathExtension lowercaseString] isEqualToString:@"avi"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"3gp"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"m4v"] || [[fileName.pathExtension lowercaseString] isEqualToString:@"mp4"]) {
                    
                    [selectedFileTypeURLs addObject:[NSURL fileURLWithPath:[appDir stringByAppendingPathComponent:fileName]]];
                }
            }
            break;
        default:
            
            break;
    }

}

#pragma mark - Directory Watcher Delegate

- (void)checkForInbox
{
    NSFileManager *defMgr = [NSFileManager defaultManager];
    
    NSString *appDir = [self applicationDocumentsDirectory];
    NSArray *contents = [defMgr contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil];
    if (!contents) {
        return;
    }
    BOOL fromOpenIn = NO;
    NSString *newFile = nil;
    if ([contents containsObject:@"Inbox"]) {
        
        NSString *inboxPath = [appDir stringByAppendingPathComponent:@"Inbox"];
        NSArray *inboxContents = [defMgr contentsOfDirectoryAtPath:inboxPath error:nil];
        
        if (inboxContents.count == 1) {
            
            fromOpenIn = YES;
        }
        NSError *err = nil;
        
        
        
        for (NSString *str in inboxContents.objectEnumerator) {
            
            NSString *f = str;
            
            [defMgr moveItemAtPath:[inboxPath stringByAppendingPathComponent:str] toPath:[appDir stringByAppendingPathComponent:f] error:&err];
            if (err) {
                if (err.code == 516) {
                    int i = 1;
                    
                    NSString *ext = [f pathExtension];
                    NSString *fn  = [f stringByDeletingPathExtension];
                    fn = [fn stringByAppendingFormat:@"-%d",i];
                    
                    do {
                        fn = [fn stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"-%d",i] withString:[NSString stringWithFormat:@"-%d",i+1]];
                        i++;
                    } while ([contents containsObject:[fn stringByAppendingPathExtension:ext]]);
                    
                    if (fromOpenIn) {
                        newFile = [NSString stringWithString:[appDir stringByAppendingPathComponent:[fn stringByAppendingPathExtension:ext]]];
                    }
                    
                    [defMgr moveItemAtPath:[inboxPath stringByAppendingPathComponent:str] toPath:[appDir stringByAppendingPathComponent:[fn stringByAppendingPathExtension:ext]] error:&err];
                    
                }else{
                    NSLog(@"%@",err.localizedDescription);
                }
                
            }else{
                if (fromOpenIn) {
                    newFile = [NSString stringWithString:[appDir stringByAppendingPathComponent:f]];
                }
            }
            
            
        }
        
        [defMgr removeItemAtPath:inboxPath error:nil];
        
    }
    
    if (newFile) {
        
        [self performSelector:@selector(openFilePreview:) withObject:newFile afterDelay:.4f];
        
    }
}

- (id)topVC
{
    UIViewController * topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    return topVC;
}

- (void)openFilePreview:(NSString *)file
{
    
    if ([NSStringFromClass([[self topVC] class]) isEqualToString:NSStringFromClass([PDFDocumentViewController class])]) {
        [(UIViewController *)[self topVC] dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    
    if ([[file.pathExtension lowercaseString] isEqualToString:@"pdf"]) {
        
        PDFDocumentViewController *vc = [[PDFDocumentViewController alloc] initWithNibName:@"PDFDocumentViewController" bundle:nil];
        vc.filePath = file;
        
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
        
    }else{
        
        UIDocumentInteractionController *dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:file]];
        dic.delegate = (id)self;
        [dic performSelector:@selector(presentPreviewAnimated:) withObject:nil afterDelay:0.5f];
        
    }
    
    
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
    [self checkForInbox];
    [self populateSelectedFileTipeURLsArrayForFileType:selectedCell];
    [self updateFilesCountDictionary];
    
    [filesTableView reloadData];

}

#pragma mark - Application Directories

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationLibraryDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -

- (NSString *)prefferedLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

#pragma mark -
- (IBAction)showHelp:(UIButton *)sender
{
    if (!helpScrollView.hidden) {
        helpScrollView.hidden = YES;
        return;
    }
    
//    [[helpScrollView viewWithTag:555] removeFromSuperview];
    
    //add new help image and set content size
    
    if ([self.view viewWithTag:1111] == filesTableView) {
        if (!showsCellWithTable) {
            CGRect r = docHelpView.frame;
            r.size.height = docHelpImg.frame.size.height;
            docHelpView.frame = r;
            r.origin = CGPointZero;
            helpImg.frame = r;
            helpImg.image = docHelpImg.image;
            
            helpScrollView.contentSize = docHelpImg.frame.size;
        }else{
            CGRect r = docHelpView.frame;
            r.size.height = filesHelpImage.frame.size.height;
            docHelpView.frame = r;
            r.origin = CGPointZero;
            helpImg.frame = r;
            helpImg.image = filesHelpImage.image;
            
            helpScrollView.contentSize = filesHelpImage.frame.size;
        }
        
    }else if ([self.view viewWithTag:1111] == downloadTab) {
        CGRect r = docHelpView.frame;
        r.size.height = downHelpImage.frame.size.height;
        docHelpView.frame = r;
        r.origin = CGPointZero;
        helpImg.frame = r;
        helpImg.image = downHelpImage.image;
        
        helpScrollView.contentSize = downHelpImage.frame.size;
    }else if ([self.view viewWithTag:1111] == settingsTab){
        CGRect r = docHelpView.frame;
        r.size.height = settingsHelpImage.frame.size.height;
        docHelpView.frame = r;
        r.origin = CGPointZero;
        helpImg.frame = r;
        helpImg.image = settingsHelpImage.image;
        
        helpScrollView.contentSize = settingsHelpImage.frame.size;
    }
    
    
    helpScrollView.hidden = NO;
    
}

#pragma mark - Switch tab

- (IBAction)switchTab:(UIButton *)sender
{
    
    if (!helpScrollView.hidden) {
        helpScrollView.hidden = YES;
    }
    
    
    
    switch (sender.tag) {
        case 1:
            if ([self.view viewWithTag:1111]!=filesTableView) {
                
                filesTableView.frame = [self frameForInterfaceOrientationForView:filesTableView];
                
                [UIView transitionWithView:self.view duration:0.3f
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^{
                                    
                                    bottomLine.backgroundColor = sender.backgroundColor;
                                    [[self.view viewWithTag:1111] removeFromSuperview];
                                    [self.view addSubview:filesTableView];
                                    
                                    
                                } completion:^(BOOL finished) {
                                    
                                }];
            }
            break;
        case 2:
            if ([self.view viewWithTag:1111]!=downloadTab) {
                
                downloadTab.frame = [self frameForInterfaceOrientationForView:downloadTab];
                
                [UIView transitionWithView:self.view duration:0.3f
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^{
                                    
                                    bottomLine.backgroundColor = sender.backgroundColor;
                                    [[self.view viewWithTag:1111] removeFromSuperview];
                                    [self.view addSubview:downloadTab];
                                    
                                    
                                } completion:^(BOOL finished) {
                                    
                                }];
            }
            break;
        case 3:
            if ([self.view viewWithTag:1111]!=settingsTab) {
                
                settingsTab.frame = [self frameForInterfaceOrientationForView:settingsTab];
                
                [UIView transitionWithView:self.view duration:0.3f
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^{
                                    
                                    bottomLine.backgroundColor = sender.backgroundColor;
                                    [[self.view viewWithTag:1111] removeFromSuperview];
                                    [self.view addSubview:settingsTab];
                                    
                                    
                                } completion:^(BOOL finished) {
                                    
                                }];
            }
            break;
        default:
            break;
    }
    
    [self.view bringSubviewToFront:helpScrollView];
}


#pragma mark -

- (void)displayInfoUpdate:(NSNotification *) notification {
	
	if(notification)
	{
		[addresses release];
		addresses = [[notification object] copy];
		NSLog(@"addressess: %@", addresses);
	}
	
	if(addresses == nil)
	{
		return;
	}
	
	UInt16 port = [httpServer port];
	
	NSString *localIP = nil;
	
	localIP = [addresses objectForKey:@"en0"];
	
	if (!localIP) {
		localIP = [addresses objectForKey:@"en1"];
	}
	
	if (!localIP){
		ip = [@"Wifi: No Connection!\n" retain];
        ipLabel.text = ip;
        return;
    }
	else
		ip = [[NSString stringWithFormat:@"%@:%d", localIP, port] retain];
    NSString *helpStr = NSLocalizedString(@"FileTransferLabelString", nil);
    ipLabel.text = [NSString stringWithFormat:@"%@   %@",helpStr,ip];
	
}

- (IBAction)fileTransferSwitchValChanged:(id)sender
{
    if ([(UISwitch *)sender isOn]) {
        ipLabel.hidden = NO;
        NSString *root = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        httpServer = [HTTPServer new];
        [httpServer setType:@"_http._tcp."];
        [httpServer setConnectionClass:[MyHTTPConnection class]];
        [httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
        [httpServer setPort:8080];
        
        NSError *error;
        if(![httpServer start:&error]) {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
        
        [self displayInfoUpdate:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAdressesResolved" object:nil];
        [localhostAddresses performSelectorInBackground:@selector(list) withObject:nil];
        
    }else{
        [httpServer stop];
        
        ipLabel.hidden = YES;
        
    }
}

- (IBAction)setLockValChanged:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        NSLog(@"SW ON ");
        SetLocker *l = [[[SetLocker alloc] initWithNibName:@"SetLocker" bundle:nil] autorelease];
        
        [self.navigationController pushViewController:l animated:YES];
    }else{
        NSLog(@"SW OFF ");
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"appLocked"]) {
            Locker *l = [[[Locker alloc] initWithNibName:@"Locker" bundle:nil] autorelease];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"dotLocked"]) {
                l.type = YES;
            }
            l.toCancel = YES;
            [self.navigationController pushViewController:l animated:YES];
        }
        
    }
    
    
}

- (IBAction)preventSleepModeValChanged:(id)sender
{
    
}

#pragma mark -

- (IBAction)showWebBrowser:(id)sender
{
    [self.navigationController pushViewController:browser animated:YES];
}

- (IBAction)clearBrowserHistory:(id)sender
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteBrowserHistory", nil)
                                                    message:nil
                                                   delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                          otherButtonTitles:NSLocalizedString(@"Clear",nil), nil] autorelease];
    alert.tag = 501;
    [alert show];
}

- (IBAction)clearBookmarks:(id)sender
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteBookmarks", nil)
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                           otherButtonTitles:NSLocalizedString(@"Clear",nil), nil] autorelease];
    
    alert.tag = 502;
    [alert show];
}

- (IBAction)clearRecentDownloads:(id)sender
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteDownloads", nil)
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                           otherButtonTitles:NSLocalizedString(@"Clear",nil), nil] autorelease];
    alert.tag = 503;
    [alert show];
}


#pragma mark - RevMob required delegate methods

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



#pragma mark -

- (IBAction)noAddsAction:(UIButton *)sender
{
    NOADDS *noadvc = [[[NOADDS alloc] initWithNibName:@"NOADDS"
                                               bundle:nil] autorelease];
    
    [self presentViewController:noadvc animated:YES completion:^{}];
    
}

#pragma mark -


- (void)dealloc {
    
    
    if (_adWhirlView) {
        [_adWhirlView removeFromSuperview];
        [_adWhirlView replaceBannerViewWith:nil];
        [_adWhirlView ignoreNewAdRequests];
        [_adWhirlView setDelegate:nil];
        [_adWhirlView release];
        _adWhirlView = nil;
    }
    
    [browser release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [dw release];
    
    [filesTableView release];
    
    [downloadTab release];
    [settingsTab release];
    [bottomLine release];
    [fileTransferSwitch release];
    [appLockSwitch release];
    [preventSleepModeSwitch release];
    [ipLabel release];
    [renameView release];
    [renameTf release];
    [helpScrollView release];
    [docHelpView release];
    [helpImg release];
    [docHelpImg release];
    [downHelpImage release];
    [settingsHelpImage release];
    [filesHelpImage release];
    [adWhirlContainer release];
    [super dealloc];
}
- (void)viewDidUnload {
    
    [browser release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [downloadTab release];
    downloadTab = nil;
    [settingsTab release];
    settingsTab = nil;
    [bottomLine release];
    bottomLine = nil;
    [fileTransferSwitch release];
    fileTransferSwitch = nil;
    [appLockSwitch release];
    appLockSwitch = nil;
    [preventSleepModeSwitch release];
    preventSleepModeSwitch = nil;
    [ipLabel release];
    ipLabel = nil;
    [renameView release];
    renameView = nil;
    [renameTf release];
    renameTf = nil;
    [helpScrollView release];
    helpScrollView = nil;
    [docHelpView release];
    docHelpView = nil;
    [helpImg release];
    helpImg = nil;
    [docHelpImg release];
    docHelpImg = nil;
    [downHelpImage release];
    downHelpImage = nil;
    [settingsHelpImage release];
    settingsHelpImage = nil;
    [filesHelpImage release];
    filesHelpImage = nil;
    [adWhirlContainer release];
    adWhirlContainer = nil;
    [super viewDidUnload];
}
@end
