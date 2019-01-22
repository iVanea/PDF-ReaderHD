//
//  BrowserViewController.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/16/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "BrowserViewController.h"

#import "BookmarksViewController.h"

#import "ConfirmView.h"

#import "NSData+Base64.h"

@interface BrowserViewController ()
{
    IBOutlet UIWebView *browserWebView;
    
    DownloadsViewController *dvc;
    BookmarksViewController *bvc;
    
    
    IBOutlet UITextField *addressField;
    IBOutlet UITableView *browserHistoryTable;
    
    NSMutableArray *browserHistory;
    
    IBOutlet UIActivityIndicatorView *pageLoadingActivityIndicator;
    
    
    IBOutlet UIButton *dButton;
    IBOutlet ConfirmView *downloadOpenView;
    
    NSData *b64imgData;
    NSString *base64imgExtension;
    
    NSString *fileURL;
    
    
    IBOutlet UIProgressView *mDownloadProgress;
    IBOutlet UIView *addBookmarkView;
    IBOutlet UITextField *bookmarksDescription;
}



@end

@implementation BrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [browserWebView loadHTMLString:@"" baseURL:nil];
    
    dvc = [[DownloadsViewController alloc] initWithNibName:@"DownloadsViewController_iPhone" bundle:nil];
    dvc.parentVC = self;
    bvc = [[BookmarksViewController alloc] initWithNibName:@"BookmarksViewController" bundle:nil];
    bvc.parentVC = self;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDissapear:) name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obsSel) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    downloadOpenView.browser = self;
    
    addBookmarkView.layer.cornerRadius = 15.0f;
}

#pragma mark -

- (void)obsSel
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sleepMode"]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

#pragma mark -

- (void)keyboardDidDissapear:(NSNotification *)notification
{
    if ([addressField isFirstResponder]) {
        return;
    }
    browserHistoryTable.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!browserHistory) {
        browserHistory = [[NSMutableArray alloc] init];
    }
    
    [browserHistory setArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"BrowsingHistory"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

#pragma mark -

- (IBAction)closeBrowser:(id)sender
{
    if (self.navigationController) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }
}

- (IBAction)showDownloads:(UIButton *)sender
{
    [self.navigationController pushViewController:dvc animated:YES];
}

- (IBAction)showBookmarks:(UIButton *)sender
{
    [self.navigationController pushViewController:bvc animated:YES];
}
- (IBAction)hideAddBookmarkView:(id)sender
{
    [UIView animateWithDuration:0.3f animations:^{
        addBookmarkView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        addBookmarkView.hidden = YES;
    }];
}

- (IBAction)addBookmark:(id)sender
{
    if (!browserWebView.request) {
        
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        addBookmarkView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        addBookmarkView.hidden = NO;
    }];
    
}
- (IBAction)createBookmark:(id)sender
{
    NSMutableDictionary *bookmarks = [NSMutableDictionary dictionary];
    
    [bookmarks setDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"bookmarks"]];
    
    [bookmarks setValue:browserWebView.request.URL.absoluteString forKey:bookmarksDescription.text];
    
    [[NSUserDefaults standardUserDefaults] setValue:bookmarks forKey:@"bookmarks"];
    
    [addBookmarkView removeFromSuperview];
}

- (IBAction)downloadOpened:(UIButton *)sender
{
    if (!browserWebView.request) {
        return;
    }
    //    [self animateAButton:downloadOpenedBtn];
    //    [self animateAButton:downloadsBtn];
    //    NSLog(@"%@",browserWebView.request.URL.absoluteString);
    //    NSLog(@"%@",vc_downloads.description);
    
    [dvc downloadURLAbsolutePath:browserWebView.request.URL.absoluteString];
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

#pragma mark - UIWebViewDelegate

- (void)releaseb64data
{
    [b64imgData release];
    b64imgData = nil;
}

- (void)loadPage:(NSURLRequest *)req
{
    [browserWebView loadRequest:req];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"LongPress");
        
        CGPoint pt = [sender locationInView:sender.view];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"jsTools" ofType:@"js"];
        
        NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        NSString *hasSRC = [browserWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hasSRC(%f,%f)",pt.x,pt.y]];
        if ([hasSRC isEqualToString:@"YES"]) {
            NSLog(@"hasSRC:%@",hasSRC);
            [downloadOpenView setDownloadButtonTitle:@"Save Image"];
        }else{
            [downloadOpenView setDownloadButtonTitle:@"Download Item"];
        }
        
        [browserWebView stringByEvaluatingJavaScriptFromString: jsCode];
        
        
        NSString *jsElementAtPoint = [browserWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hrefOrSrcOfElementAtPoint(%f,%f)",pt.x,pt.y]];
        
        NSString *dString = nil;
        if ([jsElementAtPoint rangeOfString:@"http://"].location != NSNotFound || [jsElementAtPoint rangeOfString:@"https://"].location != NSNotFound) {
            dString = [NSString stringWithString:jsElementAtPoint];
        }else if ([jsElementAtPoint rangeOfString:@"data:image"].location != NSNotFound && [jsElementAtPoint rangeOfString:@";base64,"].location !=NSNotFound) {
            
            if (b64imgData) {
                [b64imgData release],b64imgData = nil;
            }
            int loc = [jsElementAtPoint rangeOfString:@";base64,"].location + [@";base64," length];
            NSLog(@"=====================\n=======================\n%@",[jsElementAtPoint substringFromIndex:loc]);
            b64imgData = [[NSData dataFromBase64String:[jsElementAtPoint substringFromIndex:loc]] retain];
            NSLog(@"data lenght = %d",[b64imgData length]);
            
            
            loc = [jsElementAtPoint rangeOfString:@"data:image/"].length;
            int len = [jsElementAtPoint rangeOfString:@";"].location - loc;
            
            
            if (base64imgExtension) {
                [base64imgExtension release];base64imgExtension = nil;
            }
            base64imgExtension = [[jsElementAtPoint substringWithRange:NSMakeRange(loc, len)] retain];
            
            downloadOpenView.center = browserWebView.center;
            
            
            [self.view addSubview:downloadOpenView];
            _showingConfirmView = YES;
            return;
            
        }else if ([jsElementAtPoint hasSuffix:@".html"]){
            
        }else {
            dString = [NSString stringWithFormat:@"http://%@%@",browserWebView.request.URL.host,jsElementAtPoint];
        }
        
        [dString isEqualToString:fileURL] ? NSLog(@"is equal"):NSLog(@"is not");
        
        if (fileURL) {
            [fileURL release];
            fileURL = nil;
        }
        
        fileURL = [dString retain];
        
        downloadOpenView.center = browserWebView.center;
        
        [self.view addSubview:downloadOpenView];
        
        _showingConfirmView = YES;
    }
    
    
}

- (IBAction)downloadFromLongTouch:(id)sender
{
    if (b64imgData) {
        
        NSString *fname = [[self genRandStringLength:8] stringByAppendingPathExtension:base64imgExtension];
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *fpath = [docPath stringByAppendingPathComponent:fname];
        
        [b64imgData writeToFile:fpath atomically:YES];
        [downloadOpenView removeFromSuperview];
        _showingConfirmView = NO;
        [self performSelector:@selector(releaseb64data) withObject:nil afterDelay:0.5f];
        
        return;
    }
    
    if (fileURL) {
        NSLog(@"download from %@",fileURL);
        [dvc downloadURLAbsolutePath:fileURL];
        [downloadOpenView removeFromSuperview];
        _showingConfirmView = NO;
    }
    
}

- (void)readyState:(NSString *)str
{
    
    if ([str isEqualToString:@"complete"]||[str isEqualToString:@"interactive"]) {
        NSLog(@"readyState:%@",str);
        [pageLoadingActivityIndicator stopAnimating];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (_showingConfirmView) {
        return NO;
    }
    
    [pageLoadingActivityIndicator startAnimating];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    
    [self readyState:[browserWebView stringByEvaluatingJavaScriptFromString:@"document.readyState"]];
    
    if (browserHistoryTable.hidden) {
        addressField.text = webView.request.URL.absoluteString;
    }
    
    NSMutableArray *history = [NSMutableArray array];
    
    [history setArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"BrowsingHistory"]];
    
    if ([history containsObject:addressField.text]) {
        [history removeObject:addressField.text];
    }
    
    [history insertObject:addressField.text atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setValue:history forKey:@"BrowsingHistory"];
    
    [self updateBrowsingHistory];
    
    [browserWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = \"none\";"];
    [browserWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTapHighlightColor = \"rgba(0,0,0,0)\";"];
    
}

- (void)searchGoogle
{
    NSLog(@"googleSearch");
    NSString *encodedSelectedWord = [addressField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *googleStr = [NSString stringWithFormat:@"https://www.google.com/search?q=%@",encodedSelectedWord];
    [browserWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:googleStr]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@",error.description);
        if (error.code == -1009) {
            [browserWebView loadHTMLString:@"<html>\
             <head></head>\
             <body>\
             <h1>Internet connection seems to be offline</h1>\
             </body>\
             </html>" baseURL:nil];
        }
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            switch (error.code) {
                case -1003:
                    [self searchGoogle];
                    break;
                case -1100:
                    [self searchGoogle];
                    break;
                default:
                    break;
            }
        }
        
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self updateBrowsingHistory];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    browserHistoryTable.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        return;
    }
    
    NSURL *url;
    
    if ((![textField.text hasPrefix:@"http://"] || ![textField.text hasPrefix:@"https://"]) && ![textField.text isEqualToString:@"about:blank"]) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:textField.text]];
    }else{
        url = [NSURL URLWithString:textField.text];
    }
    
    
    [browserWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [browserHistoryTable setHidden:YES];
}

- (void)updateBrowsingHistory
{
    [browserHistory removeAllObjects];
    
    if ([addressField.text isEqualToString:@""] || addressField.text == NULL) {
        
        [browserHistory setArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"BrowsingHistory"]];
        [browserHistoryTable reloadData];
        
        return;
    }
    
    NSArray *hist = [[NSUserDefaults standardUserDefaults] valueForKey:@"BrowsingHistory"];
    NSMutableArray *newHist = [NSMutableArray array];
    
    for (NSString *str in hist.objectEnumerator) {
        
        NSString *entry = [NSString stringWithString:str];
        
        if ([entry rangeOfString:addressField.text].location != NSNotFound) {
            [newHist addObject:str];
        }
    }
    
    [browserHistory setArray:  [newHist sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSLiteralSearch];
    }]];
    
    [browserHistoryTable reloadData];
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
    return browserHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    cell.textLabel.text = [browserHistory objectAtIndex:indexPath.row];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [browserHistory removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[NSUserDefaults standardUserDefaults] setValue:browserHistory forKey:@"BrowsingHistory"];
    }
    //    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    //        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //    }
}


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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [addressField resignFirstResponder];
    NSString *str = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [browserWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    
}

#pragma mark -

#pragma mark -

//- (void)needToAnimateDownloadsButton:(BOOL)needToAnimate
//{
//    if (needToAnimate) {
//        if (!loadingIndicator.isAnimating) {
//            [loadingIndicator startAnimating];
//        }
//    }else{
//        [loadingIndicator stopAnimating];
//    }
//}

- (void)set_mDownloadProgressValue:(float)value
{
    if (value> 0.0f) {
        mDownloadProgress.hidden = NO;
    }else{
        mDownloadProgress.hidden = YES;
    }
    [mDownloadProgress setProgress:value];
}


#pragma mark - Dealloc and viewDidUnload

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [bvc release];
    [dvc release];
    [browserWebView release];
    [addressField release];
    [browserHistoryTable release];
    [pageLoadingActivityIndicator release];
    [dButton release];
    [downloadOpenView release];
    [mDownloadProgress release];
    [addBookmarkView release];
    [bookmarksDescription release];
    [super dealloc];
}
- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [bvc release],bvc = nil;
    [dvc release],dvc = nil;
    [browserWebView release];
    browserWebView = nil;
    [addressField release];
    addressField = nil;
    [browserHistoryTable release];
    browserHistoryTable = nil;
    [pageLoadingActivityIndicator release];
    pageLoadingActivityIndicator = nil;
    [dButton release];
    dButton = nil;
    [downloadOpenView release];
    downloadOpenView = nil;
    [mDownloadProgress release];
    mDownloadProgress = nil;
    [addBookmarkView release];
    addBookmarkView = nil;
    [bookmarksDescription release];
    bookmarksDescription = nil;
    [super viewDidUnload];
}
@end
