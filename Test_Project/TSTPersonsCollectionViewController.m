//
//  TSTTestViewController.m
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/9/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTPersonsCollectionViewController.h"
#import "TSTDataProvider.h"
#import "TSTAppDelegate.h"
#import "TSTPerson.h"
#import "TSTPersonCollectionViewCell.h"
#import "TSTPersonDetailsTableViewController.h"
#import "TSTListsViewMediator.h"

@interface TSTPersonsCollectionViewController () <TSTListener>

@property (nonatomic, strong) id <TSTDataProvider, TSTObservable> dataProvider;
@property (nonatomic, strong) TSTListsViewMediator *collectionViewMediator;


@end

@implementation TSTPersonsCollectionViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _dataProvider = [TSTAppDelegate sharedDelegate].dataProvider;
        _collectionViewMediator = [[TSTListsViewMediator alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [self.dataProvider removeListener:_collectionViewMediator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionViewMediator.collectionView = self.collectionView;
    [self.dataProvider addListener:self.collectionViewMediator];

    self.navigationItem.rightBarButtonItem = [self addPersonButton];
}

- (UIBarButtonItem *)addPersonButton {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson:)];
}

- (void)addPerson:(id)sender {
    TSTPerson *person = [[TSTPerson alloc] init];
    person.firstName = @"John";
    person.lastName = @"Doe";
    [self.dataProvider addObject:person];
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataProvider.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TSTPerson *person = [self.dataProvider objectAtIndex:(NSUInteger) indexPath.row];
    
    TSTPersonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PersonCell" forIndexPath:indexPath];
    [cell setupWithPerson:person];
    
    return cell;
}

#pragma mark - Interface orientation methods

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UICollectionViewCell *)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TSTPersonDetailsTableViewController *details = segue.destinationViewController;
    NSUInteger index = [self.collectionView indexPathForCell:sender].row;
    TSTPerson *person = [self.dataProvider objectAtIndex:index];
    details.person = person;
}

@end
