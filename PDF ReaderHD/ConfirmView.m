//
//  ConfirmView.m
//  pdfReaderUniv
//
//  Created by Jora Kalorifer on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfirmView.h"

#import "BrowserViewController.h"

@interface ConfirmView ()
{
    IBOutlet UIButton *dButton;
}



@end

@implementation ConfirmView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
//    _browser.showingConfirmView = NO;
}

- (void)setDownloadButtonTitle:(NSString *)str
{
    [dButton setTitle:str forState:UIControlStateNormal];
}

@end
