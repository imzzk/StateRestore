//
//  MyViewController.h
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item, MyViewController;

@protocol MyViewControllerDelegate;

@interface MyViewController : UIViewController

@property(nonatomic,strong)Item *item;

@property(nonatomic,weak) id<MyViewControllerDelegate>delegate;


@end


@protocol MyViewControllerDelegate <NSObject>
@required
-(void)editHasEnded:(MyViewController *)viewController withItem:(Item *)item;
@end