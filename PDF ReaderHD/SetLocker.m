//
//  SetLocker.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/16/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//



#import "SetLocker.h"



@interface SetLocker ()
{
    
    IBOutlet UISegmentedControl *modeSegment;
    IBOutlet UIView *setPassView;
    IBOutlet UIView *setDotLocView;
    IBOutlet UITextField *enterPass_tf;
    IBOutlet UITextField *confirmPass_tf;
}

@end

@implementation SetLocker

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
    
    BSKeyLock *kl = [[BSKeyLock alloc] initWithFrame:CGRectMake(0, 0, 660, 600)];
    kl.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin);
    [setDotLocView addSubview:kl];
    kl.backgroundColor = [UIColor clearColor];
    kl.center = [setDotLocView convertPoint:setDotLocView.center fromView:self.view];
    kl.delegate = self;
    
    
    
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

- (void)viewDidAppear:(BOOL)animated
{
    
    
    
}

#pragma mark -

- (void)validateKeyCombination:(NSArray *)keyCombination sender:(id)sender
{
    if([keyCombination count] > 3)
	{
		// Store the combo and remove the keypad.
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
		[settings setObject:keyCombination forKey:@"KeyLockCombo"];
		[settings synchronize];
		
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"appLocked"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dotLocked"];
        
		if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                [(BSKeyLock *)sender touchesBegan:nil withEvent:nil];
            }];
        }
		
	}
	else
	{
		[(BSKeyLock*)sender deemKeyCombinationInvalid];
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
    if (textField == enterPass_tf) {
        if (textField.text.length < 4) {
            [self shake:textField];
        }else{
            [confirmPass_tf becomeFirstResponder];            
        }
    
    }else{
        if ([confirmPass_tf.text isEqualToString:enterPass_tf.text]) {
            [textField resignFirstResponder];
        }else{

            [self shake:textField];
            return NO;
        }
    
    }
    return YES;
}

#pragma mark -


- (IBAction)showView:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        setDotLocView.hidden = NO;
        setPassView.hidden = YES;
    }else{
        setDotLocView.hidden = YES;
        setPassView.hidden = NO;
    }
}

#pragma mark -

- (IBAction)hideKeyboard:(id)sender
{
    [enterPass_tf resignFirstResponder];
    [confirmPass_tf resignFirstResponder];
}

#pragma mark -

- (IBAction)acceptPassword:(UIButton *)sender
{
    if ([enterPass_tf.text isEqualToString:confirmPass_tf.text] && enterPass_tf.text.length >= 4) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"appLocked"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dotLocked"];
        [[NSUserDefaults standardUserDefaults] setValue:enterPass_tf.text forKey:@"psswrd"];
        
        [self cancelPassSeting:nil];
        
    }else{
        [self shake:enterPass_tf];
        [self shake:confirmPass_tf];
    }
}
- (IBAction)cancelPassSeting:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)dealloc {
    [setPassView release];
    [modeSegment release];
    [setDotLocView release];
    [enterPass_tf release];
    [confirmPass_tf release];
    [super dealloc];
}
- (void)viewDidUnload {
    [setPassView release];
    setPassView = nil;
    [modeSegment release];
    modeSegment = nil;
    [setDotLocView release];
    setDotLocView = nil;
    [enterPass_tf release];
    enterPass_tf = nil;
    [confirmPass_tf release];
    confirmPass_tf = nil;
    [super viewDidUnload];
}
@end
