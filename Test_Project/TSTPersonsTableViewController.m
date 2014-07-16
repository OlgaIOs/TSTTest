//
//  TSTPersonsTableViewController.m
//  Test_Project
//
//  Created by Sergey Kovalenko on 6/27/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTPersonsTableViewController.h"
#import "TSTDataProvider.h"
#import "TSTPerson.h"
#import "TSTAppDelegate.h"
#import "TSTPersonDetailsTableViewController.h"
#import "TSTPersonTableViewCell.h"
#import "TSTListsViewMediator.h"

@interface TSTPersonsTableViewController ()

@property (nonatomic, strong) id <TSTDataProvider, TSTObservable> dataProvider;
@property (nonatomic, strong) TSTListsViewMediator *tableViewMediator;

@end

@implementation TSTPersonsTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dataProvider = [TSTAppDelegate sharedDelegate].dataProvider;
        _tableViewMediator = [[TSTListsViewMediator alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_dataProvider removeListener:_tableViewMediator];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableViewMediator.tableView = self.tableView;
    [self.dataProvider addListener:self.tableViewMediator];
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

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TSTPerson *person = [self.dataProvider objectAtIndex:(NSUInteger) indexPath.row];
    
    TSTPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    [cell setupWithPerson:person];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataProvider removeObjectAtIndex:indexPath.row];
    }
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TSTPersonDetailsTableViewController *details = segue.destinationViewController;
    NSUInteger index = [self.tableView indexPathForCell:sender].row;
    details.person = [self.dataProvider objectAtIndex:index];
}


@end
