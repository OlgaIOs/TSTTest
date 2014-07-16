//
//  TSTListsViewMediator.h
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/16/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSTObservable.h"

@interface TSTListsViewMediator : NSObject <TSTListener>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end
