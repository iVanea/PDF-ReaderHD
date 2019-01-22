//
//  Locker.h
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/16/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BSKeyLock.h"

@interface Locker : UIViewController <BSKeyLockDelegate, UITextFieldDelegate>

@property (assign) BOOL type;//YES for password
@property (assign) BOOL toCancel;//YES if lock need to be turned off

@end
