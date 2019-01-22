//
//  ViewController.m
//  test
//
//  Created by Jora Kalorifer on 2/16/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
    IBOutlet UIWebView *webview_;
    NSString  *textString;
    unsigned long curentEncoding;
    
    NSString *textEncodingName;
    IBOutlet UIActivityIndicatorView *acind;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSString *path = [[NSBundle  mainBundle] pathForResource:@"zel" ofType:@"txt"];
//    
//    textString = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] retain];
//    
//    [webview_ loadData:[textString dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:nil];
//    
//    curentEncoding = NSUTF8StringEncoding;
    
    UIImage *img = [self screenshot];
    NSData *d = UIImagePNGRepresentation(img);
    [webview_ loadData:d MIMEType:@"image/png" textEncodingName:@"UTF-8" baseURL:nil];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)loadStringWithEncoding:(unsigned long)enc encName:(NSString *)encName
{
    
    NSData *dtl = [textString dataUsingEncoding:enc];
    
    [webview_ loadData:dtl MIMEType:@"text/plain" textEncodingName:encName baseURL:nil];
    
    curentEncoding = enc;
}


- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)readyState:(NSString *)str
{
    NSLog(@"str:%@",str);
    
    if ([str isEqualToString:@"complete"]||[str isEqualToString:@"interactive"]) {
        NSLog(@"IT HAS BEEN DONE");
        [acind stopAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self readyState:[webview_ stringByEvaluatingJavaScriptFromString:@"document.readyState"]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Should");
    [acind startAnimating];
    return YES;
}

- (IBAction)changeEncoding:(UIButton *)sender
{
    
    unsigned long encoding;
    NSString *encName;
    
    [webview_ loadHTMLString:@"" baseURL:nil];
    
    switch (sender.tag) {
        case 1:
            encoding = NSUTF8StringEncoding;
            encName = @"UTF-8";
            break;
        case 2:
            encoding = NSUTF16StringEncoding;
            encName = @"UTF-16";
            break;
        case 3:
            encoding = NSUTF32StringEncoding;
            encName = @"UTF-32";
            break;
        case 4:
            encoding = NSASCIIStringEncoding;
            encName = @"ASCII";
            break;
        case 5:
            encoding = NSNEXTSTEPStringEncoding;
            encName = @"NEXTSTEP";
            break;
        case 6:
            encoding = NSJapaneseEUCStringEncoding;
            encName = @"JapaneseEUC";
            break;
        case 7:
            encoding = NSSymbolStringEncoding;
            encName = @"Symbol";
            break;
        case 8:
            encoding = NSNonLossyASCIIStringEncoding;
            encName = @"NonLossyASCII";
            break;
        case 9:
            encoding = NSShiftJISStringEncoding;
            encName = @"ShiftJIS";
            break;
        case 10:
            encoding = NSISOLatin2StringEncoding;
            encName = @"ISOLatin2";
            break;
        case 11:
            encoding = NSUnicodeStringEncoding;
            encName = @"Unicode";
            break;
        case 12:
            encoding = NSWindowsCP1251StringEncoding;
            encName = @"WindowsCP1251";
            break;
        case 13:
            encoding = NSWindowsCP1252StringEncoding;
            encName = @"WindowsCP1252";
            break;
        case 14:
            encoding = NSWindowsCP1253StringEncoding;
            encName = @"WindowsCP1253";
            break;
        case 15:
            encoding = NSWindowsCP1254StringEncoding;
            encName = @"WindowsCP1254";
            break;
        case 16:
            encoding = NSWindowsCP1250StringEncoding;
            encName = @"WindowsCP1250";
            break;
        case 17:
            encoding = NSISO2022JPStringEncoding;
            encName = @"ISO2022JP";
            break;
        case 18:
            encoding = NSMacOSRomanStringEncoding;
            encName = @"MacOSRoman";
            break;
        case 19:
            encoding = NSUTF16BigEndianStringEncoding;
            encName = @"UTF-16";
            break;
        case 20:
            encoding = NSUTF16LittleEndianStringEncoding;
            encName = @"UTF-16";
            break;
        case 21:
            encoding = NSUTF32BigEndianStringEncoding;
            encName = @"UTF-32";
            break;
        case 22:
            encoding = NSUTF32LittleEndianStringEncoding;
            encName = @"UTF-32";
            break;
        default:
            encoding = NSASCIIStringEncoding;
            encName = @"ASCII";
            break;
    }
    
    [self loadStringWithEncoding:encoding encName:encName];
}
- (void)dealloc {
    [webview_ release];
    [acind release];
    [super dealloc];
}
@end
