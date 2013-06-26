//
//  MyTableViewController.h
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyViewController.h"

@interface MyTableViewController : UITableViewController<UIDataSourceModelAssociation,
                                    MyViewControllerDelegate,
                                    UIActionSheetDelegate>

@end
