//
//  Item.m
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import "Item.h"

@implementation Item

-(NSArray *)keysForEncoding
{
    return [NSArray arrayWithObjects:@"title",@"notes",@"identifier", nil];
}

-(id)initWithTitle:(NSString *)title notes:(NSString *)notes
{
    self = [super init];
    if(self)
    {
        self.title = title;
        self.notes = notes;
        NSUUID *uuid = [[NSUUID alloc] init];
        self.identifier = [uuid UUIDString];
    }
    return self;
}

// we are being created based on what was archived earlier
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        for (NSString *key in self.keysForEncoding)
        {
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

// we are asked to be archived, encode all our data
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	for (NSString *key in self.keysForEncoding)
    {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

@end
