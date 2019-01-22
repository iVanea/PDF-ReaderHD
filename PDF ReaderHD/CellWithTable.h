//
//  CellWithTable.h
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/7/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuickLook/QuickLook.h>

#import "PopupMenu.h"

@protocol CellWithTableDelegate

- (void)deleteItem:(id)item;
- (void)renameItem:(id)item;

@end

@interface CellWithTable : UITableViewCell <UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIAlertViewDelegate>



@property (nonatomic, assign) id<CellWithTableDelegate>delegate;
@property (nonatomic, assign) NSArray *dataArray;
@property (nonatomic, assign) unsigned fileTypeSelected;

- (void)updateTableViewFrame;

- (void)renameItem:(int)itm;
- (void)deleteItem:(int)itm;

@end
