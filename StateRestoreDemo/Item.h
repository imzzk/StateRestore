//
//  Item.h
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property(nonatomic,strong) NSString *identifier;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *notes;

-(id)initWithTitle:(NSString *)title notes:(NSString *)notes;


@end
