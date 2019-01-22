//
//  ConfirmView.h
//  pdfReaderUniv
//
//  Created by Jora Kalorifer on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BrowserViewController;

@interface ConfirmView : UIView

- (void)setDownloadButtonTitle:(NSString *)str;
@property (nonatomic, assign) BrowserViewController *browser;
@end
