//
//  PopupMenu.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/11/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "PopupMenu.h"

#import "CellWithTable.h"

@interface PopupMenu ()

@end

@implementation PopupMenu

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.frame = CGRectMake(0, 0, 320, 320);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIView *v = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView = v;
        [v release];
        
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    // Configure the cell...
    if (_popoverController_.popoverArrowDirection == UIPopoverArrowDirectionUp) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Rename", nil);
                cell.backgroundView.backgroundColor = [UIColor colorWithRed:76.0f/255.0f green:154.0f/255.0f blue:0.0f alpha:1.0f];
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Delete", nil);
                cell.backgroundView.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Cancel", nil);
                cell.backgroundView.backgroundColor = [UIColor blackColor];
                break;
            default:
                break;
        }
        
        
    }else if (_popoverController_.popoverArrowDirection == UIPopoverArrowDirectionDown){
        cell.textLabel.text = [NSString stringWithFormat:@"Cell %d",3-indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Cancel", nil);
                cell.backgroundView.backgroundColor = [UIColor blackColor];
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Delete", nil);
                cell.backgroundView.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Rename", nil);
                cell.backgroundView.backgroundColor = [UIColor colorWithRed:76.0f/255.0f green:154.0f/255.0f blue:0.0f alpha:1.0f];
                break;
            default:
                break;
        }
        
    }

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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}
*/

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
    
    if (self.popoverController_.popoverArrowDirection == UIPopoverArrowDirectionUp) {
        switch (indexPath.row) {
            case 0://ren
                [self.cwt renameItem:_itemIndex];
                break;
            case 1://del
                [self.cwt deleteItem:_itemIndex];
                break;
            case 2://canc
//                [self.popoverController_ dismissPopoverAnimated:YES];
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
//                [self.popoverController_ dismissPopoverAnimated:YES];
                break;
            case 1:
                [self.cwt deleteItem:_itemIndex];
                break;
            case 2:
                [self.cwt renameItem:_itemIndex];
                break;
            default:
                break;
        }
    }
    [self.popoverController_ dismissPopoverAnimated:YES];
}

@end
