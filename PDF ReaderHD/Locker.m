//
//  Locker.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/16/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "Locker.h"



@interface Locker ()
{
    
    IBOutlet UIView *keyLockContainer;
    IBOutlet UIView *passLock;
    
    BSKeyLock *dotLocker;
    IBOutlet UITextField *passLock_tf;
}

@end

@implementation Locker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    dotLocker = [[BSKeyLock alloc] initWithFrame:CGRectMake(0, 0, keyLockContainer.frame.size.width, keyLockContainer.frame.size.height)];
    dotLocker.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|
                                  UIViewAutoresizingFlexibleTopMargin|
                                  UIViewAutoresizingFlexibleLeftMargin|
                                  UIViewAutoresizingFlexibleRightMargin);
    dotLocker.backgroundColor = [UIColor clearColor];
    dotLocker.delegate = self;
    [keyLockContainer addSubview:dotLocker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)viewWillAppear:(BOOL)animated
{
    if (_type) {
        passLock.hidden = NO;
        [passLock_tf becomeFirstResponder];
    }else{
        passLock.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
}
#pragma mark -

-(void)validateKeyCombination:(NSArray*)keyCombination sender:(id)sender
{
    if (_toCancel) {
        if ([keyCombination isEqualToArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"KeyLockCombo"]]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"appLocked"];
            
            [dotLocker touchesBegan:nil withEvent:nil];
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }else{
            [(BSKeyLock *)sender deemKeyCombinationInvalid];
        }
    }else{
        if ([keyCombination isEqualToArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"KeyLockCombo"]]) {
            [dotLocker touchesBegan:nil withEvent:nil];
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }else{
            [(BSKeyLock *)sender deemKeyCombinationInvalid];
        }
    }
}

#pragma mark -

-(void)shake:(UIView *)theOneYouWannaShake
{
    static int direction = 1;
    static int shakes = 0;
    
    [UIView animateWithDuration:0.05 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5*direction, 0);
     }
                     completion:^(BOOL finished)
     {
         if(shakes >= 10)
         {
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             shakes = 0;
             direction = 1;
             return;
         }
         shakes++;
         direction = direction * -1;
         [self shake:theOneYouWannaShake];
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_toCancel) {
        if (![textField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"psswrd"]]) {
            
            
            [self shake:textField];
            
            return NO;
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"appLocked"];
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }else{
        if (![textField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"psswrd"]]) {
            
            
            [self shake:textField];
            
            return NO;
        }
        
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
    
    return YES;
}

#pragma mark -

- (void)dealloc {
    [keyLockContainer release];
    [passLock release];
    [passLock_tf release];
    [super dealloc];
}
- (void)viewDidUnload {
    [keyLockContainer release];
    keyLockContainer = nil;
    [passLock release];
    passLock = nil;
    [passLock_tf release];
    passLock_tf = nil;
    [super viewDidUnload];
}
@end
