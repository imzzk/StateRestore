//
//  DataSource.h
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface DataSource : NSObject

+(DataSource *)sharedInstance;

-(NSInteger)count;

-(void)addItem:(Item *)item;
-(Item *)itemAtIndex:(NSInteger)index;
-(void)removeItemAtIndex:(NSInteger)index;
-(void)insertItem:(Item *)item atIndex:(NSInteger)index;
-(void)replaceItemAtIndex:(NSInteger)index withObject:(Item *)item;
-(Item *)itemWithIdentifier:(NSString *)identifier;
-(NSIndexPath *)indexPathForItem:(Item *)item;
-(void)save;

@end
