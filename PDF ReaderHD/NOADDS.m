//
//  NOADDS.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 4/24/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "NOADDS.h"

@interface NOADDS ()

@end

@implementation NOADDS

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)gotoURL:(id)sender
{
    NSString *s = @"https://itunes.apple.com/us/app/pdf-doc-xls-ppt-txt-reader-hd/id640000345?l=ru&ls=1&mt=8";
    NSURL *url = [NSURL URLWithString:s];
    [[UIApplication sharedApplication] openURL:url];
}

@end
