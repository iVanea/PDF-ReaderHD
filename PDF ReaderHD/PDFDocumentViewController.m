//
//  PDFDocumentViewController.m
//  newPDFReaderUniv
//
//  Created by Jora Kalorifer on 2/1/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "PDFDocumentViewController.h"



const NSString *bookmarksDictionaryKey = @"pdfDocumentsBookmarks";

@interface PDFDocumentViewController ()
{
    
    IBOutlet UIView *containerView;
    
    PDFDocumentScrollView *pdfDocScroll;
    IBOutlet UIView *addBookmarkMenuView;
    IBOutlet UIView *allBookmarksView;
    IBOutlet UIView *createBookmarkView;
    IBOutlet UITextField *createBookmarkTextField;
    IBOutlet UIView *gotoPageView;
    
    NSMutableDictionary *thisDocBookmarks;
    IBOutlet UITableView *allBookmarksTableView;
    IBOutlet UILabel *pageLabel;
    IBOutlet UITextField *searchTextField;
    IBOutlet UIImageView *hideSearchImage;
    IBOutlet UILabel *docNameLabel;
    
    
    NSMutableArray *allSearchResults;
    
    IBOutlet UILabel *noBookmarksLabel;
    IBOutlet UIButton *showOptionsButton;
    
    UIDocumentInteractionController *docInteractionController;
    IBOutlet UIButton *closeSearchBtn;
    IBOutlet UIButton *searchButton;
    
    
    int searchResultsCount;
    int srchIndx;
    NSMutableString *sString;
    
    BOOL isFullScreen;
    
    UIView *hv;
    
}

@end

@implementation PDFDocumentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hv = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    thisDocBookmarks  = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDissapear:) name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obsSel) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}
#pragma mark -

- (void)obsSel
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sleepMode"]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

#pragma mark -
- (void)keyboardDidChange:(NSNotification*)notification
{
//    NSDictionary* keyboardInfo = [notification userInfo];
//    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
//    
//    CGRect r = pdfDocScroll.frame;
//    
//    r.size.height = self.view.frame.size.height - keyboardFrameBeginRect.size.height - pdfDocScroll.frame.origin.y;
//    pdfDocScroll.frame = r;
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    CGRect r = containerView.frame;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        r.size.height = self.view.frame.size.height - keyboardFrameBeginRect.size.height - containerView.frame.origin.y;
        containerView.frame = r;
        r.origin = CGPointZero;
        r.size.height = containerView.frame.size.height;
    }else{
        r.size.height = self.view.frame.size.width - keyboardFrameBeginRect.size.width - containerView.frame.origin.y;
        containerView.frame = r;
        r.origin = CGPointZero;
        r.size.height = containerView.frame.size.height;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        pdfDocScroll.frame = r;
    }];
    
    
}

- (void)keyboardDidDissapear:(NSNotification*)notification
{
    CGRect fullSc = [[UIScreen mainScreen] bounds];
    
    
    
    __block CGRect partSc = CGRectMake(0, 106, fullSc.size.width, fullSc.size.height-224);
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        CGFloat w = fullSc.size.width;
        fullSc.size.width = fullSc.size.height;
        fullSc.size.height = w;
        
        partSc = CGRectMake(0, 106, fullSc.size.width, fullSc.size.height-224);
    }
    
    if (isFullScreen) {
        containerView.frame = fullSc;
        pdfDocScroll.frame = fullSc;
    }else{
        containerView.frame = partSc;
        partSc.origin = CGPointZero;
        pdfDocScroll.frame = partSc;
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([addBookmarkMenuView isDescendantOfView:self.view]) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            
            [UIView animateWithDuration:.2f animations:^{
                addBookmarkMenuView.center = CGPointMake(self.view.center.y, self.view.center.x);
            }];
            
        }else{
            
            [UIView animateWithDuration:.2f animations:^{
                addBookmarkMenuView.center = self.view.center;
            }];
            
        }
    }
    
//    if ([allBookmarksView isDescendantOfView:self.view]) {
//        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//            [UIView animateWithDuration:.2f animations:^{
//                allBookmarksView.center = CGPointMake(self.view.center.y, self.view.center.x);
//            }];
//            
//        }else{
//            [UIView animateWithDuration:.2f animations:^{
//                allBookmarksView.center = self.view.center;
//            }];
//            
//        }
//    }
    
    if ([gotoPageView isDescendantOfView:self.view]) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            [UIView animateWithDuration:.2f animations:^{
                gotoPageView.center = CGPointMake(self.view.center.y, self.view.center.x - 75);
            }];
            
        }else{
            [UIView animateWithDuration:.2f animations:^{
                gotoPageView.center = CGPointMake(self.view.center.x, self.view.center.y-75);
            }];
            
        }
    }
    
    if ([createBookmarkView isDescendantOfView:self.view]) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            [UIView animateWithDuration:.2f animations:^{
                createBookmarkView.center = CGPointMake(self.view.center.y, self.view.center.x-75);
            }];
            
        }else{
            [UIView animateWithDuration:.2f animations:^{
                createBookmarkView.center = CGPointMake(self.view.center.x, self.view.center.y-75);
            }];
            
        }
    }
    
    
    [pdfDocScroll centerTheContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [pdfDocScroll centerTheContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    if (_filePath) {
        CGRect r = {CGPointZero,containerView.frame.size};
        if (pdfDocScroll) {
            [pdfDocScroll release],pdfDocScroll = nil;
        }
        
        CGPDFDocumentRef docref = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:_filePath]);
        
        pdfDocScroll = [[[PDFDocumentScrollView alloc] initWithFrame:r andDocument:docref documentPath:_filePath] autorelease];
        
        CGPDFDocumentRelease(docref);
        
        pdfDocScroll.PDFDocDelegate = self;
        
        pdfDocScroll.maximumZoomScale = 30;
        
        pdfDocScroll.minimumZoomScale = 0.5;
        
        pdfDocScroll.decelerationRate = UIScrollViewDecelerationRateFast;
        
        pdfDocScroll.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                         UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         
                                         UIViewAutoresizingFlexibleWidth);
        
        
        
        [containerView addSubview:pdfDocScroll];
//        [self.view addSubview:pdfDocScroll];
        
        
        NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:(NSString *)bookmarksDictionaryKey];
        
        if (dict == nil) {
            dict = [[NSMutableDictionary alloc] init];
        }
        
        if (!thisDocBookmarks) {
            thisDocBookmarks  = [[NSMutableDictionary alloc] init];
        }
        
        thisDocBookmarks.dictionary = [dict valueForKey:_filePath.lastPathComponent];
        
        docNameLabel.text = _filePath.lastPathComponent;
        
        [self updatePageLabel];
        
        
        docInteractionController = [[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:_filePath]] retain];
        

        
        
    }
}


- (void)updatePageLabel
{
    [pageLabel setText:[NSString stringWithFormat:@"%d / %d",[pdfDocScroll getCurrentPageNumberDisplayed],(unsigned int)pdfDocScroll.numberOfPages]];
}

- (IBAction)closeAction:(id)sender
{
    if (!allBookmarksView.hidden) {
        [UIView animateWithDuration:0.3f animations:^{
            allBookmarksView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            allBookmarksView.hidden = YES;
        }];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        pdfDocScroll.PDFDocDelegate = nil;
        [pdfDocScroll removeFromSuperview];
        
        
    }];
}
- (IBAction)tapAction:(UITapGestureRecognizer *)sender
{
    NSLog(@"tap");
    if ([addBookmarkMenuView isDescendantOfView: self.view]) {
        [addBookmarkMenuView removeFromSuperview];
        return;
    }
    
    if ([createBookmarkView isDescendantOfView: self.view]) {
        [createBookmarkView removeFromSuperview];
        return;
    }
    
    if (!allBookmarksView.hidden) {
        
        
        
        [UIView animateWithDuration:0.3f animations:^{
            allBookmarksView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            allBookmarksView.hidden = YES;
        }];
        
        return;
    }
    
    
    CGRect fullSc = [[UIScreen mainScreen] bounds];
    
    
    
    __block CGRect partSc = CGRectMake(0, 106, fullSc.size.width, fullSc.size.height-224);
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        CGFloat w = fullSc.size.width;
        fullSc.size.width = fullSc.size.height;
        fullSc.size.height = w;
        
        partSc = CGRectMake(0, 106, fullSc.size.width, fullSc.size.height-224);
    }
    if (isFullScreen) {
        if (pdfDocScroll) {
            [UIView animateWithDuration:0.3f animations:^{
                containerView.frame = partSc;
                partSc.origin = CGPointZero;
                pdfDocScroll.frame = partSc;
            } completion:^(BOOL finished) {
                if (!searchTextField.hidden) {
                    [searchTextField becomeFirstResponder];
                }
            }];
        }
    }else{
        if (pdfDocScroll) {
            [UIView animateWithDuration:0.3f animations:^{
                containerView.frame = fullSc;
//                fullSc.origin = CGPointZero;
                pdfDocScroll.frame = fullSc;
                
            }];
            
        }
    }
    
    isFullScreen = !isFullScreen;
    
    
    if (searchTextField.isFirstResponder) {
        [searchTextField resignFirstResponder];
    }
}

#pragma mark - bookmarks

- (IBAction)bookmarkButtonAction:(UIButton *)sender
{
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        addBookmarkMenuView.center = CGPointMake(self.view.center.y, self.view.center.x);
    }else{
        addBookmarkMenuView.center = self.view.center;
    }
    
    addBookmarkMenuView.alpha = 0.0f;
    createBookmarkTextField.text = [NSString stringWithFormat:@"Page :%d",[pdfDocScroll getCurrentPageNumberDisplayed]];
    [self.view addSubview:addBookmarkMenuView];
    [UIView animateWithDuration:0.3f animations:^{
        addBookmarkMenuView.alpha = 1.0f;
    }];
}

- (IBAction)addNewBookmark:(UIButton *)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        addBookmarkMenuView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [addBookmarkMenuView removeFromSuperview];
        createBookmarkView.alpha = 0.0f;
        
        
        
        [self.view addSubview:createBookmarkView];
        
        
        
        [UIView animateWithDuration:0.3f animations:^{
            
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                createBookmarkView.center = CGPointMake(self.view.center.y, self.view.center.x-75);
                
            }else{
                createBookmarkView.center = CGPointMake(self.view.center.x, self.view.center.y-75);
                
            }
            
            createBookmarkTextField.text = @"";
            
            createBookmarkView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [createBookmarkTextField becomeFirstResponder];
        }];
    }];
}

- (IBAction)createBookmark:(UIButton *)sender
{
    if (pdfDocScroll) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict.dictionary = [[NSUserDefaults standardUserDefaults] valueForKey:(NSString *)bookmarksDictionaryKey];
        
        
        if (dict == nil) {
            dict = [[NSMutableDictionary alloc] init];
            
            [dict setValue:[NSDictionary dictionary] forKey:_filePath.lastPathComponent];
            
        }
        
        if (!thisDocBookmarks) {
            thisDocBookmarks  = [[NSMutableDictionary alloc] init];
        }
        
        if (dict) {
            thisDocBookmarks.dictionary = [dict valueForKey:_filePath.lastPathComponent];
        }
//        [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]
//        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
        
//        NSString *valStr = [NSString stringWithFormat:@"%@ | Page:%d",dateString,[pdfDocScroll getCurrentPageNumberDisplayed]];
        
        NSArray *valArr = @[[NSDate date],[NSNumber numberWithInt:[pdfDocScroll getCurrentPageNumberDisplayed]]];
        [thisDocBookmarks setValue:valArr forKey:createBookmarkTextField.text];
        
        [dict setValue:thisDocBookmarks forKey:_filePath.lastPathComponent];
        
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:(NSString *)bookmarksDictionaryKey];
        
        
        [UIView animateWithDuration:0.3f animations:^{
            createBookmarkView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [addBookmarkMenuView removeFromSuperview];
            [allBookmarksTableView reloadData];
        }];
    }
    
    [allBookmarksTableView reloadData];
    
}



- (IBAction)showAllBookmarks:(UIButton *)sender
{
    
    
    [allBookmarksTableView reloadData];
    
//    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//        
//        allBookmarksView.frame = CGRectMake(0, 0, 302, 200);
//        
//        allBookmarksView.center = CGPointMake(self.view.center.y, self.view.center.x);
//        
//        
//    }else{
//        
//        allBookmarksView.frame = CGRectMake(0, 0, 259, 302);
//        
//        allBookmarksView.center = self.view.center;
//    }
    
    if (allBookmarksView.hidden) {
        [UIView animateWithDuration:0.3f animations:^{
            addBookmarkMenuView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
            [addBookmarkMenuView removeFromSuperview];
            
            allBookmarksView.alpha = 0.0f;
            allBookmarksView.hidden = NO;
            [self.view addSubview:allBookmarksView];
            
            [UIView animateWithDuration:0.3f animations:^{
                allBookmarksView.alpha = 1.0f;
                
            }];
            
        }];
    }else{
        [UIView animateWithDuration:0.3f animations:^{
            allBookmarksView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
            allBookmarksView.hidden = YES;
            
        }];
    }
    
    
    
    
//    [dict release];
    
}


- (IBAction)clearBookmarks:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ClearBookmarks", nil)
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Clear", nil), nil];
    [[alert autorelease] show];
}


#pragma mark - UITableViewDelegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setDictionary:[[[NSUserDefaults standardUserDefaults] valueForKey:(NSString *)bookmarksDictionaryKey] valueForKey:_filePath.lastPathComponent]];
    
    
    if (dict.allKeys.count == 0) {
        noBookmarksLabel.hidden = NO;
    }else{
        noBookmarksLabel.hidden = YES;
    }
    
    return dict.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.detailTextLabel.numberOfLines = 5;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_cell_.png"]];
        v.autoresizingMask = (UIViewAutoresizingFlexibleHeight
                              |UIViewAutoresizingFlexibleWidth
                              |UIViewAutoresizingFlexibleLeftMargin
                              |UIViewAutoresizingFlexibleRightMargin
                              |UIViewAutoresizingFlexibleTopMargin
                              |UIViewAutoresizingFlexibleBottomMargin
                              );
        cell.backgroundView = v;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        [v release];
    }
    
    
    
    NSArray *arr = [thisDocBookmarks.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSArray *a = [thisDocBookmarks valueForKey:obj1];
        NSArray *b = [thisDocBookmarks valueForKey:obj2];
        
        NSDate *d1 = [a objectAtIndex:0];
        
        
        NSDate *d2 = [b objectAtIndex:0];
        
        
        return [d2 compare:d1];
        
    }];
    
    
    
    if (thisDocBookmarks.allKeys.count > 0) {
        cell.textLabel.text = [arr objectAtIndex:indexPath.row];
        //угадай с первой попытки что это такое
        cell.detailTextLabel.text = [NSString
                                     stringWithFormat:@"%@ | Page:%d",[NSDateFormatter
                                                                       localizedStringFromDate:[[thisDocBookmarks
                                                                                                 valueForKey:[arr objectAtIndex:indexPath.row]]
                                                                                                objectAtIndex:0]
                                                                                                              dateStyle:NSDateFormatterLongStyle
                                                                                                              timeStyle:NSDateFormatterShortStyle]
                                     ,
                                     [[[thisDocBookmarks valueForKey:[arr objectAtIndex:indexPath.row]] lastObject] intValue]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *detLabText = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
    
    NSArray *detLabComp = [detLabText componentsSeparatedByString:@"|"];
    
    NSString *pgStr = [detLabComp lastObject];
    
    NSString *pn = [pgStr substringFromIndex:[pgStr rangeOfString:@":"].location+1];

    int page = [pn integerValue];
    
    [pdfDocScroll goToPage:page animated:YES];
    
    [self tapAction:nil];
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
        
        if (_filePath) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict.dictionary = [[NSUserDefaults standardUserDefaults] valueForKey:(NSString *)bookmarksDictionaryKey];
            
            NSLog(@"dict:%@",dict.description);
            if (dict == nil) {
                dict = [[NSMutableDictionary alloc] init];
                
                [dict setValue:[NSDictionary dictionary] forKey:_filePath.lastPathComponent];
                NSLog(@"dict:%@",dict.description);
            }
            
            if (!thisDocBookmarks) {
                thisDocBookmarks  = [[NSMutableDictionary alloc] init];
            }
            
            if (dict) {
                thisDocBookmarks.dictionary = [dict valueForKey:_filePath.lastPathComponent];
            }
            
            [thisDocBookmarks removeObjectForKey:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            
            [dict setValue:thisDocBookmarks forKey:_filePath.lastPathComponent];
            
            [[NSUserDefaults standardUserDefaults] setValue:dict forKey:(NSString *)bookmarksDictionaryKey];
            
            [allBookmarksTableView reloadData];
        }
        
        
    }

}

#pragma mark -
- (IBAction)prevPage:(UIButton *)sender
{
    [pdfDocScroll goPreviousPage];
//    int page = [pdfDocScroll getCurrentPageNumberDisplayed];
//    page--;
//    [pdfDocScroll goToPage:page animated:YES];
//    [self updatePageLabel];
//    [self performSelector:@selector(updatePageLabel) withObject:nil afterDelay:0.3f];
}
- (IBAction)nextPage:(UIButton *)sender
{
    [pdfDocScroll goNextPage];
//    int page = [pdfDocScroll getCurrentPageNumberDisplayed];
//    page++;
//    [pdfDocScroll goToPage:page animated:YES];
//    [self updatePageLabel];
//    [self performSelector:@selector(updatePageLabel) withObject:nil afterDelay:0.3f];
    
}
- (IBAction)showGotoPageMenu:(UIButton *)sender
{
    gotoPageView.center = self.view.center;
    [self.view addSubview:gotoPageView];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [UIView animateWithDuration:.2f animations:^{
            gotoPageView.center = CGPointMake(self.view.center.y, self.view.center.x-75);
        }];
        
    }else{
        [UIView animateWithDuration:.2f animations:^{
            gotoPageView.center = CGPointMake(self.view.center.x, self.view.center.y-75);
        }];
        
    }
    [(UITextField *)[gotoPageView viewWithTag:555]  becomeFirstResponder];
}

- (IBAction)gotoPage
{
    unsigned long pageNumber = [(UITextField *)[gotoPageView viewWithTag:555] text].integerValue;
    NSLog(@"page number : %ld",pageNumber);
    
    [pdfDocScroll goToPage:pageNumber animated:YES];
    [gotoPageView removeFromSuperview];
    [(UITextField *)[gotoPageView viewWithTag:555] setText:@""];
}
- (IBAction)cancelGotoPage:(id)sender
{
    [gotoPageView removeFromSuperview];
}

- (IBAction)searchButtonTapped:(UIButton *)sender
{
    static float hideSrchWidth = -1;
    if (hideSrchWidth < 0) {
        hideSrchWidth = hideSearchImage.frame.size.width;
    }
    CGRect r = hideSearchImage.frame;
    
    if (searchTextField.hidden) {
        hv.hidden = NO;
        [sender setImage:[UIImage imageNamed:@"ipad_search_btn"] forState:UIControlStateNormal];
        r.size.width = hideSrchWidth;
        searchTextField.hidden = NO;
        hideSearchImage.hidden = NO;
        docNameLabel.hidden = YES;
        closeSearchBtn.alpha = 0.0f;
        closeSearchBtn.hidden = NO;
        [searchTextField becomeFirstResponder];
        [UIView animateWithDuration:0.2f animations:^{
            hideSearchImage.frame = r;
            showOptionsButton.alpha = 0.0f;
            closeSearchBtn.alpha = 1.0f;
        } completion:^(BOOL finished) {
            showOptionsButton.hidden = YES;
            
        }];
    }else{
//        [self removeHighLightingFromDocument:pdfDocScroll];
        [sender setImage:[UIImage imageNamed:@"ipad_search_btn"] forState:UIControlStateNormal];
        r.size.width = 0;
        
        searchTextField.hidden = YES;
        hv.hidden = YES;
        showOptionsButton.hidden = NO;
        [UIView animateWithDuration:0.2f animations:^{
            hideSearchImage.frame = r;
            closeSearchBtn.alpha = 0.0f;
            showOptionsButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            closeSearchBtn.hidden = YES;
            docNameLabel.hidden = NO;
            hideSearchImage.hidden = YES;
            [searchTextField resignFirstResponder];
        }];
    }
}

#pragma mark -

#pragma marl - Search Logic

- (void)searchNext:(BOOL)newSearch
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    
    if (!hv) {
        hv = [[UIView alloc] initWithFrame:CGRectZero];
        
    }
    
    int curPageNum = [pdfDocScroll getCurrentPageNumberDisplayed];
    
    if (srchIndx >= allSearchResults.count) {
        srchIndx = 0;
    }
    
    if (allSearchResults.count < 1){
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No matches found"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }
    
    if (newSearch) {
        for (MFTextItem *ti in allSearchResults.objectEnumerator) {
            
            if (ti.page == curPageNum) {
                srchIndx = [allSearchResults indexOfObject:ti];
                PDFPageView *currentPageView = [pdfDocScroll getCurrentPageViewDisplayed];
                hv.backgroundColor = [MFTextItem highlightYellowColor];
                CGRect r = CGPathGetBoundingBox(ti.highlightPath);
                hv.frame = CGRectMake(r.origin.x, currentPageView.frame.size.height-r.origin.y-r.size.height, r.size.width, r.size.height);
                if (![hv isDescendantOfView:currentPageView]) {
                    [hv removeFromSuperview];
                    [currentPageView addSubview:hv];
                }
                
                [pdfDocScroll scrollRectToVisible:[pdfDocScroll convertRect:hv.frame fromView:currentPageView] animated:YES];
                srchIndx++;
                return;
            }
        }
    }
    
    MFTextItem *ti = [allSearchResults objectAtIndex:srchIndx];
    
    if ([pdfDocScroll getCurrentPageNumberDisplayed]!=ti.page) {
        [pdfDocScroll goToPage:ti.page animated:NO];
    }
    
    PDFPageView *currentPageView = [pdfDocScroll getPDFPageViewWithNumber:ti.page];
    hv.backgroundColor = [MFTextItem highlightYellowColor];
    CGRect r = CGPathGetBoundingBox(ti.highlightPath);
    hv.frame = CGRectMake(r.origin.x, currentPageView.frame.size.height-r.origin.y-r.size.height, r.size.width, r.size.height);
    if (hv.hidden) {
        hv.hidden = NO;
    }
    if (![hv isDescendantOfView:currentPageView]) {
        [hv removeFromSuperview];
        [currentPageView addSubview:hv];
    }
    [pdfDocScroll scrollRectToVisible:[pdfDocScroll convertRect:hv.frame fromView:currentPageView] animated:YES];
    srchIndx++;
    
    
//    NSArray *curPageArr = [allSearchResults objectAtIndex:curPageNum-1];
//    
//    if (srchIndx >= curPageArr.count) {
//        if(++curPageNum>=allSearchResults.count){curPageNum = 0;}
//        srchIndx = 0;
//        [pdfDocScroll goNextPage];
//        curPageArr = [allSearchResults objectAtIndex:curPageNum];
//        while (curPageArr.count==0) {
//            if(++curPageNum >= allSearchResults.count){
//                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Matchs not found"
//                                                                 message:nil
//                                                                delegate:self
//                                                       cancelButtonTitle:NSLocalizedString(@"Close", nil)
//                                                       otherButtonTitles: nil] autorelease];
//                [alert show];
//                return;
//            }
//            curPageArr = [allSearchResults objectAtIndex:curPageNum];
//            
//            
//        } 
//        
//    }
//    
//    NSLog(@"srchIndx:%d  arr.c:%@",srchIndx,curPageArr.description);
//    MFTextItem *ti = [curPageArr objectAtIndex:srchIndx];
//    
//    [pdfDocScroll goToPage:ti.page animated:NO];
//    
//    
//    
//    
//    hv.backgroundColor = [MFTextItem highlightYellowColor];
////    CGRectMake(rectBox.origin.x, currentPageView.frame.size.height-rectBox.origin.y-rectBox.size.height, rectBox.size.width, rectBox.size.height)
//    PDFPageView *currentPageView = [pdfDocScroll getCurrentPageViewDisplayed];
//    
//    CGRect r = CGPathGetBoundingBox(ti.highlightPath);
//    hv.frame = CGRectMake(r.origin.x, currentPageView.frame.size.height-r.origin.y-r.size.height, r.size.width, r.size.height);
//    
//    if (![hv isDescendantOfView:currentPageView]) {
//        [hv removeFromSuperview];
//        [currentPageView addSubview:hv];
//    }
//
//    [pdfDocScroll scrollRectToVisible:[pdfDocScroll convertRect:hv.frame fromView:currentPageView] animated:YES];
//    
//    srchIndx ++;
    
}

- (void)searchTerm:(UIAlertView *)alert searchString:(NSString*)searchString
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (hv.hidden) {
        hv.hidden = NO;
    }
    searchResultsCount = 0;
    MFDocumentManager *docManager = nil;
    docManager = [[MFDocumentManager alloc]initWithFileUrl:[NSURL fileURLWithPath:_filePath]];
    [docManager tryUnlockWithPassword:@"1234"];
    
    int numP = [pdfDocScroll numberOfPages];
    for (int i = 0; i < numP; i++) {
        
        if (searchTextField.hidden) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            float prgs = (float)(i+1)/(float)numP;
            
            if (prgs > [(UIProgressView *)[alert viewWithTag:100]  progress]) {
                [(UIProgressView *)[alert viewWithTag:100] setProgress:prgs];
            }
            
        });
        
        
        NSArray *sr = [docManager searchResultOnPage:i+1 forSearchTerms:searchString];
        if (sr) {
            [allSearchResults addObjectsFromArray:sr];
        }
        
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        srchIndx = 0;
        [self searchNext:YES];
        
    });
    
    
    
    
    
}


- (void)startSearch
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (searchTextField.text.length == 0) {
        return;
    }
    
    
    if (!sString) {
        sString = [[NSMutableString alloc] init];
    }
    
    if (!allSearchResults) {
        allSearchResults = [[NSMutableArray alloc] init];
    }
    
    if ([searchTextField.text isEqualToString:sString]) {
        //need to search next
        [self searchNext:NO];
    }else{
        //need to search new word
        
        [allSearchResults removeAllObjects];
        [self removeHighLightingFromDocument:pdfDocScroll];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Searching\n\n\n\n\n\n"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles: nil];
        alert.tag = 534;
        
        UIActivityIndicatorView *actInd = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        [actInd startAnimating];
        [alert show];
        [alert addSubview:actInd];
        
        CGPoint cc = [alert convertPoint:alert.center fromView:alert.superview];
        
        actInd.center = CGPointMake(cc.x, cc.y - 15);
        UIProgressView *prg = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        prg.tag = 100;
        
        [alert addSubview:prg];
        prg.center = CGPointMake(actInd.center.x, actInd.center.y + actInd.frame.size.height + 20);
        
        NSString *ss = searchTextField.text;
        
        dispatch_queue_t destination_queue = dispatch_queue_create("newQ", NULL);
        
        
        dispatch_async(destination_queue, ^{
            
            // code here to update UI
            [self searchTerm:alert searchString:ss];
            
        });
        
        //[self performSelectorInBackground:@selector(searchTerm:) withObject:alert];
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
//    PDFPageView *currentPageView = [pdfDocScroll getCurrentPageViewDisplayed];
    
    
//    NSString *termToSearch = [searchTextField text];
//    int searchRange = [pdfDocScroll getCurrentPageNumberDisplayed];
////    for (int i = [pdfDocScroll getCurrentPageNumberDisplayed]; i <= searchRange; i++) {
//        NSArray *searchResultsForCurrentPage = [docManager searchResultOnPage:searchRange forSearchTerms:termToSearch];
//        
//        // sort results by Y drawing position
//        NSMutableArray *sortedResultsForCurrentPage = [[NSMutableArray alloc ] initWithArray:searchResultsForCurrentPage];
//        int length = [sortedResultsForCurrentPage count];
//        for (int s=0; s<length; s++) {
//            MFTextItem *currentTextItem = [sortedResultsForCurrentPage objectAtIndex:s];
//            CGRect pathBox = CGPathGetBoundingBox([currentTextItem highlightPath]);
//            float max = pathBox.origin.y;  int maxIndex = s;
//            for (int j=s; j<length; j++) {
//                MFTextItem *currentTextItem = [sortedResultsForCurrentPage objectAtIndex:j];
//                CGRect pathBox = CGPathGetBoundingBox([currentTextItem highlightPath]);
//                float currentYPos = pathBox.origin.y;
//                if (currentYPos>max) { max = currentYPos; maxIndex = j; }
//            }
//            [sortedResultsForCurrentPage exchangeObjectAtIndex:s withObjectAtIndex:maxIndex];
//            
//            
//        }
    
//        //end sorting=========================
//        for (MFTextItem *currentTextItem in [sortedResultsForCurrentPage autorelease]) {
//            NSDictionary *currentSearchResult = [[NSDictionary alloc] initWithObjectsAndKeys:currentTextItem, @"MFTextItem", [NSNumber numberWithInt:searchRange], @"pageNumber",  nil];
//            [allSearchResults addObject:[currentSearchResult autorelease] ];
//            CGRect rectBox = CGPathGetPathBoundingBox([currentTextItem highlightPath]);
//            UIView *higlightView = [[UIView alloc] initWithFrame:CGRectMake(rectBox.origin.x, currentPageView.frame.size.height-rectBox.origin.y-rectBox.size.height, rectBox.size.width, rectBox.size.height)];
//            higlightView.tag = 749;//l33t tag
//            higlightView.backgroundColor = [UIColor yellowColor];
//            higlightView.alpha = 0.5;
//            [currentPageView addSubview:[higlightView autorelease] ];
//            
//            
//            
//        }
    
        
        
//    [pdfDocScroll scrollRectToVisible:[[currentPageView viewWithTag:749] frame] animated:YES];
    
    
    
    [sString setString:searchTextField.text];
}

- (IBAction)closeAll:(id)sender
{
    [UIView animateWithDuration:0.3f animations:^{
        allBookmarksView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        allBookmarksView.hidden = YES;
        
    }];
}
- (IBAction)closeSearch:(id)sender {
    
    [sString setString:@""];
    searchTextField.text = @"";
    [self searchButtonTapped:searchButton];
}

-(void) removeHighLightingFromDocument:(PDFDocumentScrollView *) theMyPDFDocument {
    // NSLog(@" removeHighLightingFromDocument");
    if (theMyPDFDocument==nil || theMyPDFDocument.numberOfPages<=0) { NSLog(@" check for errors 23412"); return; }
    for (NSInteger i=1; i<=theMyPDFDocument.numberOfPages; i++) {
        PDFPageView *currentPageView = [theMyPDFDocument getPDFPageViewWithNumber:i];
        for (UIView *currentSubview in currentPageView.subviews) {
            if (currentSubview.tag==749) { [currentSubview removeFromSuperview]; }
            }
        }
}

-(void) removeHighLightingFromPage:(PDFPageView *) myPDFPage {
    if (myPDFPage==nil || [myPDFPage.subviews count]<=0) { return; }
    for (UIView *currentSubview in myPDFPage.subviews) {
        if (currentSubview.tag==749) { [currentSubview removeFromSuperview]; }
        }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.tag == 1) {//bookmarks
        
        [self createBookmark:nil];
        textField.text = @"";
    }else if (textField == searchTextField){//search
        [self startSearch];
        return YES;
    }else if (textField.tag == 555){//gotoPage
        [self gotoPage];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 534 && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Cancel", nil)]) {
        NSLog(@"YOBSNA");
        [self closeSearch:nil];
        
        return;
    }

}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
        
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Clear", nil)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:(NSString *)bookmarksDictionaryKey]];
        if ([dict valueForKey:_filePath.lastPathComponent]) {
            [dict setValue:nil forKey:_filePath.lastPathComponent];
        }
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:(NSString *)bookmarksDictionaryKey];
        
        [allBookmarksTableView reloadData];
    }
}

#pragma mark -

- (void)pdfDocumentScrollView:(PDFDocumentScrollView *)pdfDocumentScrollView didScrollToPage:(NSInteger)currentPage
{
    static unsigned int prevPage = 0;
    
    if ([addBookmarkMenuView isDescendantOfView:self.view]){
        [createBookmarkTextField setText:[NSString stringWithFormat:@"Page :%d",[pdfDocScroll getCurrentPageNumberDisplayed]]];
    }
    
//    if (docNameLabel.hidden && currentPage != prevPage) {//then search is active
//        NSLog(@"Search");
//        [self startSearch];
//    }
    [self updatePageLabel];
    
    prevPage = currentPage;
}

- (void)pdfDocumentScrollView:(PDFDocumentScrollView *)pdfDocumentScrollView didZoomToScale:(float)scale withView:(UIView *)zoomedView
{
    
}

#pragma mark -

- (IBAction)moreOptions:(id)sender
{
    [docInteractionController presentOptionsMenuFromRect:[(UIButton*)sender frame] inView:self.view animated:YES];
}



#pragma mark -

//- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
//{
//    return self;
//}
//
//- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action
//{
//    return YES;
//}

- (void)setFilePath:(NSString *)filePath
{
    
    _filePath = [[filePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
}

#pragma mark -

- (void)dealloc {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [docInteractionController release];
    [containerView release];
    [addBookmarkMenuView release];
    [allBookmarksView release];
    [createBookmarkView release];
    [createBookmarkTextField release];
    [allBookmarksTableView release];
    [pageLabel release];
    [searchTextField release];
    [hideSearchImage release];
    [docNameLabel release];
    [allSearchResults release];
    [noBookmarksLabel release];
    [showOptionsButton release];
    [gotoPageView release];
    [closeSearchBtn release];
    [searchButton release];
    [_tap release];
    
    [super dealloc];
}
- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [docInteractionController release];
    
    [pdfDocScroll removeFromSuperview];
    
    
    [allSearchResults release];
    [containerView release];
    containerView = nil;
    [addBookmarkMenuView release];
    addBookmarkMenuView = nil;
    [allBookmarksView release];
    allBookmarksView = nil;
    [createBookmarkView release];
    createBookmarkView = nil;
    [createBookmarkTextField release];
    createBookmarkTextField = nil;
    [allBookmarksTableView release];
    allBookmarksTableView = nil;
    [pageLabel release];
    pageLabel = nil;
    [searchTextField release];
    searchTextField = nil;
    [hideSearchImage release];
    hideSearchImage = nil;
    [docNameLabel release];
    docNameLabel = nil;
    [noBookmarksLabel release];
    noBookmarksLabel = nil;
    [showOptionsButton release];
    showOptionsButton = nil;
    [gotoPageView release];
    gotoPageView = nil;
    [closeSearchBtn release];
    closeSearchBtn = nil;
    [searchButton release];
    searchButton = nil;
    [self setTap:nil];
    [super viewDidUnload];
}
@end
