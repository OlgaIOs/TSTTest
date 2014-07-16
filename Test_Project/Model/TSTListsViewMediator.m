//
//  TSTListsViewMediator.m
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/16/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTListsViewMediator.h"
@interface TSTListsViewMediator ()
@property (nonatomic, strong) NSMutableArray *changeBlocks;
@end

@implementation TSTListsViewMediator

#pragma mark - Private Methods

- (void)beginCollectionViewUpdates {
    if (self.collectionView) {
        self.changeBlocks = [NSMutableArray array];
    }
}

- (void)addChangeBlock:(void(^)(void))block {
    [self.changeBlocks addObject:block];
}

- (void)endCollectionViewUpdates {
    __weak TSTListsViewMediator *weakSelf = self;

    [self.collectionView performBatchUpdates:^{
        for (void (^updateBlock)(void) in weakSelf.changeBlocks) {
            updateBlock();
        }
    } completion:^(BOOL finished) {
        weakSelf.changeBlocks = nil;
    }];
}

#pragma mark - TSTListener protocol methods

- (void)observableObjectWillChangeContent:(id <TSTObservable>)observable userInfo:(NSMutableDictionary *)userInfo {
    [self.tableView beginUpdates];
    [self beginCollectionViewUpdates];
}

- (void)observableObject:(id <TSTObservable>)observable
         didChangeObject:(id)anObject
                 atIndex:(NSUInteger)index
           forChangeType:(TSTListenerChangeType)type
                userInfo:(NSMutableDictionary *)userInfo {
    NSArray *changedIndexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
    __weak TSTListsViewMediator *weakSelf = self;
    switch (type)
    {
        case TSTListenerChangeTypeInsert:{
            [self.tableView insertRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self addChangeBlock:^{
                [weakSelf.collectionView insertItemsAtIndexPaths:changedIndexPaths];
            }];
        }
            break;
        case TSTListenerChangeTypeDelete:{
            [self.tableView deleteRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self addChangeBlock:^{
                [weakSelf.collectionView deleteItemsAtIndexPaths:changedIndexPaths];
            }];
        }
            break;
        case TSTListenerChangeTypeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self addChangeBlock:^{
                [weakSelf.collectionView reloadItemsAtIndexPaths:changedIndexPaths];
            }];
        }
            break;
    }
}

- (void)observableObjectDidChangeContent:(id <TSTObservable>)observable userInfo:(NSMutableDictionary *)userInfo {
    [self.tableView endUpdates];
    [self endCollectionViewUpdates];
}

@end
