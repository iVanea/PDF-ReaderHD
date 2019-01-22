//
//  BookmarksViewController.m
//  newPDFReaderUniv
//
//  Created by Jora Kalorifer on 17.12.12.
//  Copyright (c) 2012 SoftInterCom. All rights reserved.
//

#import "BookmarksViewController.h"

#import "BrowserViewController.h"

@interface BookmarksViewController ()
{
    NSMutableDictionary *bookmarksDictionary;
    IBOutlet UITableView *bookmarksTable;
}
- (IBAction)closeBookmarks:(id)sender;

@end

@implementation BookmarksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        bookmarksDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [bookmarksDictionary setDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:@"bookmarks"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [bookmarksTable reloadData];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeBookmarks:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bookmarksDictionary.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_cell_.png"]];
        cell.backgroundView = back;
        [back release];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
    }
    
    cell.textLabel.text = [bookmarksDictionary.allKeys objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [bookmarksDictionary.allKeys objectAtIndex:indexPath.row];
    [_parentVC loadPage:[NSURLRequest requestWithURL:[NSURL URLWithString:[bookmarksDictionary valueForKey:key]]]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
        
        // Delete the row from the data source
        NSLog(@"docs Tab delete");
        
        NSString *bmark = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        
        //                filesViewTopLabel.text = [NSString stringWithFormat:@"%d",filesViewTopLabel.text.integerValue - 1];
        //
        ////                [self fileTypeSelected:nil];
        //                NSLog(@"dilet = %d",fileTypeSelected);
        //                afterDelete = YES;
        //                [self performSelector:@selector(fileTypeSelected:) withObject:[filesView viewWithTag:fileTypeSelected] afterDelay:0.3f];
        
        UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete Bookmark :" message:[bmark stringByAppendingString:@"\t ?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alert show];
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        
        [bookmarksDictionary removeObjectForKey:[alertView.message stringByReplacingOccurrencesOfString:@"\t ?" withString:@""]];
        
        [bookmarksTable reloadData];
        
        [[NSUserDefaults standardUserDefaults] setValue:bookmarksDictionary forKey:@"bookmarks"];
    }
    
    
}

#pragma mark -

- (void)dealloc {
    [bookmarksTable release];
    [super dealloc];
}
@end
