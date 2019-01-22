//
//  CellWithTable.m
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/7/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import "CellWithTable.h"

#import "PDFDocumentViewController.h"

@interface CellWithTable ()
{
    UITableView *_tb;
    
    unsigned qlSelectedIndex;
}



@end

@implementation CellWithTable

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        _tb.delegate = self;
        _tb.dataSource = self;
        _tb.autoresizingMask = (UIViewAutoresizingFlexibleHeight
                                |UIViewAutoresizingFlexibleWidth
                                |UIViewAutoresizingFlexibleLeftMargin
                                |UIViewAutoresizingFlexibleRightMargin
                                |UIViewAutoresizingFlexibleTopMargin
                                |UIViewAutoresizingFlexibleBottomMargin
                                );
        _tb.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0f];
        _tb.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tb];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateTableViewFrame
{
    CGRect r = _tb.frame;
    r.size.width = self.frame.size.width;
    _tb.frame = r;
}

- (void)createTableView
{
    
}

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    [_tb reloadData];
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
    if (!_dataArray.count) {
        return 1;
    }
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_cell"]];
        imgView.autoresizingMask = (UIViewAutoresizingFlexibleHeight
                                    |UIViewAutoresizingFlexibleWidth
                                    |UIViewAutoresizingFlexibleLeftMargin
                                    |UIViewAutoresizingFlexibleRightMargin
                                    |UIViewAutoresizingFlexibleTopMargin
                                    |UIViewAutoresizingFlexibleBottomMargin
                                    );
        cell.backgroundView = imgView;
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        cell.gestureRecognizers = @[lp];
        
    }
    
    cell.backgroundColor = [UIColor darkGrayColor];
    // Configure the cell...
    if (_dataArray.count == 0) {
        cell.textLabel.text = @"No Files";
    }else{
        cell.textLabel.text = [(NSURL *)[_dataArray objectAtIndex:indexPath.row] lastPathComponent];
    }
//    cell.textLabel.text = [NSString stringWithFormat:@"cell %d",indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}



/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
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
    
    NSLog(@"did selected");
    NSLog(@"selectedCell:%d",_fileTypeSelected);
    if (_dataArray.count > 0) {
        
        qlSelectedIndex = indexPath.row;
        
        if (_fileTypeSelected == 0) {
            
            
            
            NSString *filePath = [(NSURL *)[_dataArray objectAtIndex:indexPath.row] path];
            
            PDFDocumentViewController *vc = [[[PDFDocumentViewController alloc] initWithNibName:@"PDFDocumentViewController" bundle:nil] autorelease];
            vc.filePath = filePath;
            
            [[(UIViewController *)self.delegate navigationController] presentViewController:vc animated:YES completion:^{
                
            }];
            
        }else{
            QLPreviewController *ql = [[[QLPreviewController alloc] init] autorelease];
            
            ql.delegate = self;
            ql.dataSource = self;
            
            // start previewing the document at the current section index
            
            ql.currentPreviewItemIndex = 0;
            

            [ql.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
            [ql.navigationController.toolbar setBarStyle:UIBarStyleBlack];
            [[(UIViewController *)self.delegate navigationController] presentViewController:ql animated:YES completion:^{
                
            }];
//            [[(UIViewController *)self.delegate navigationController] setNavigationBarHidden:NO];
//            [[(UIViewController *)self.delegate navigationController] pushViewController:ql animated:YES];
            
        }
    }
    
    
    
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (_dataArray.count == 0) {
        return NO;
    }
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_delegate deleteItem:[_dataArray objectAtIndex:indexPath.row]];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - QLDELEGATE

#pragma mark - Preview View Controller delegate/datasource


- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    UIColor *barColor;
    
    switch (_fileTypeSelected) {
        case 0:
            barColor = [UIColor colorWithRed:0.98f green:0.23f blue:0.12f alpha:1.0f];
            break;
        case 1:
            barColor = [UIColor colorWithRed:0.09f green:0.67f blue:0.97f alpha:1.0f];
            break;
        case 2:
            barColor = [UIColor colorWithRed:0.44f green:0.65f blue:0.11f alpha:1.0f];
            break;
        case 3:
            barColor = [UIColor colorWithRed:1.0f green:0.34f blue:0.11f alpha:1.0f];
            break;
        case 4:
            barColor = [UIColor colorWithRed:0.42f green:0.62f blue:0.69f alpha:1.0f];
            break;
        case 5:
            barColor = [UIColor colorWithRed:0.95f green:0.20f blue:0.34f alpha:1.0f];
            break;
        case 6:
            barColor = [UIColor colorWithRed:1.00f green:0.820f blue:0.0f alpha:1.0f];
            break;
            
    }
    
    for (id object in controller.childViewControllers)
    {
        if ([object isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController = object;
            navController.navigationBar.tintColor = barColor;
            navController.toolbar.tintColor = barColor;
        }
    }
    
    
    
    return [_dataArray objectAtIndex:qlSelectedIndex];
}

#pragma mark -

- (void)longPressAction:(UILongPressGestureRecognizer *)sender
{
    UITableViewCell *c = (UITableViewCell *)sender.view;
    
    if ([c.textLabel.text isEqualToString:@"No Files"]) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"longPress");
        PopupMenu *pp = [[[PopupMenu alloc] initWithNibName:@"PopupMenu" bundle:nil] autorelease];
        
        pp.cwt = self;
        
        pp.itemIndex = [_tb indexPathForCell:(UITableViewCell *)sender.view].row;
        
        UIPopoverController *ppc = [[UIPopoverController alloc] initWithContentViewController:pp];
        pp.popoverController_ = ppc;
        
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        ppc.popoverContentSize = CGSizeMake(320, 222);
        [ppc presentPopoverFromRect:[vc.view convertRect:sender.view.frame fromView:self] inView:vc.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Delete", nil)]) {
        [_delegate deleteItem:[_dataArray objectAtIndex:alertView.tag]];
    }
}

- (void)deleteItem:(int)itm
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AreYouSureYouWantToDeleteFile", nil)
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Delete", nil),nil] autorelease];
    alert.tag = itm;
    [alert show];
    
}

- (void)renameItem:(int)itm
{
    [_delegate renameItem:[_dataArray objectAtIndex:itm]];
}
@end
