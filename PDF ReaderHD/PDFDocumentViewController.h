//
//  PDFDocumentViewController.h
//  newPDFReaderUniv
//
//  Created by Jora Kalorifer on 2/1/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

#import "PDFDocumentScrollView.h"

#import "MFDocumentManager.h"
#import "MFTextItem.h"



@interface PDFDocumentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PDFDocumentScrollViewDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSString *filePath;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tap;

@end
