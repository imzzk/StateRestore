//
//  DataSource.m
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import "DataSource.h"

@interface DataSource()
@property(nonatomic, strong)NSMutableArray *dataArray;
@end

@implementation DataSource

+ (DataSource *)sharedInstance
{
    static dispatch_once_t  onceToken;
    static DataSource * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[DataSource alloc] init];
    });
    return sSharedInstance;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        NSURL  *dataFileURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SavaData"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dataFileURL path]]) {
            _dataArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[[dataFileURL path] mutableCopy]];
            
        }
        else
        {
            _dataArray = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSInteger)count
{
    return self.dataArray.count;
}

- (void)addItem:(Item *)item
{
    [self.dataArray addObject:item];
}

- (Item *)itemAtIndex:(NSInteger)index
{
    return [self.dataArray objectAtIndex:index];
}

- (void)removeItemAtIndex:(NSInteger)index
{
    [self.dataArray removeObjectAtIndex:index];
}

- (void)insertItem:(Item *)item atIndex:(NSInteger)index;
{
    [self.dataArray insertObject:item atIndex:index];
}

- (void)replaceItemAtIndex:(NSInteger)index withObject:(Item *)item
{
    [self.dataArray replaceObjectAtIndex:index withObject:item];
}

- (Item *)itemWithIdentifier:(NSString *)identifier
{
    return [self.dataArray objectAtIndex:[self.dataArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        *stop = [[obj identifier] isEqual:identifier];
        return *stop;
    }]];
}

- (NSIndexPath *)indexPathForItem:(Item *)item
{
    return [NSIndexPath indexPathForRow:[self.dataArray indexOfObject:item] inSection:0];
}

- (void)save
{
    NSURL *dataFileURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SavedData"];
    [NSKeyedArchiver archiveRootObject:self.dataArray toFile:[dataFileURL path]];
}


@end
