//
//  PopupMenu.h
//  PDF ReaderHD
//
//  Created by Jora Kalorifer on 2/11/13.
//  Copyright (c) 2013 SoftInterCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellWithTable;

@interface PopupMenu : UITableViewController

@property (nonatomic, assign) UIPopoverController *popoverController_;
@property (nonatomic, assign) CellWithTable *cwt;
@property (nonatomic, assign) int itemIndex;

@end
