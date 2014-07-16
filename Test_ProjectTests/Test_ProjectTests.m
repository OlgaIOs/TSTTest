//
//  Test_ProjectTests.m
//  Test_ProjectTests
//
//  Created by Anton Kuznetsov on 6/17/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSTDataProvider.h"
#import "TSTPerson.h"

@interface Test_ProjectTests : XCTestCase

@property (nonatomic, strong) TSTDataProvider *dataProvider;
@property (nonatomic, assign) NSUInteger willChangeCount;
@property (nonatomic, assign) NSUInteger didChangeCount;
@property (nonatomic, strong) TSTPerson *testPerson;
@property (nonatomic, strong) NSMutableArray *changes;


@end

@interface Test_ProjectTests () <TSTListener>
@end

@implementation Test_ProjectTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 20; i++)
    {
        TSTPerson *person = [[TSTPerson alloc] init];
        person.firstName = [NSString stringWithFormat:@"Name %d", i];
        [array addObject:person];
    }
    self.willChangeCount = 0;
    self.didChangeCount = 0;

    self.dataProvider = [[TSTDataProvider alloc] initWithArray:array];
    [self.dataProvider addListener:self];
    
    self.changes = [NSMutableArray array];

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.dataProvider removeListener:self];
    self.dataProvider = nil;
    self.changes = nil;
}

- (void)testCount
{
    XCTAssertTrue([self.dataProvider count] == 20);
}

- (void)testListenerAdd
{
    self.testPerson = [TSTPerson new];
    self.testPerson.firstName = @"test";
    [self.dataProvider addObject:self.testPerson];
    NSDate *finish = [NSDate dateWithTimeIntervalSinceNow:10];
    
    while (self.didChangeCount != 1 && [[finish laterDate:[NSDate date]] isEqualToDate:finish]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    XCTAssertTrue(self.willChangeCount == 1);
    XCTAssertTrue(self.didChangeCount == 1);

}

- (void)testListenerRemove
{
    self.testPerson = [self.dataProvider objectAtIndex:self.dataProvider.count - 1];
    [self.dataProvider removeObject:self.testPerson];
    XCTAssertTrue(self.willChangeCount == 1);
    
    NSDate *finish = [NSDate dateWithTimeIntervalSinceNow:10];
    while (self.didChangeCount != 1 && [[finish laterDate:[NSDate date]] isEqualToDate:finish]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
        
    XCTAssertTrue(self.didChangeCount == 1);
}

- (void)testSave
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"testcontacts"];
    XCTAssertTrue([self.dataProvider saveToFile:path error:nil]);
    
    TSTDataProvider *data = [[TSTDataProvider alloc] initWithContentOfFile:path];
    for (NSUInteger i = 0; i < data.count; ++i) {
        id obj1 = [data objectAtIndex:i];
        id obj2 = [self.dataProvider objectAtIndex:i];
        XCTAssertEqualObjects(obj1, obj2);
    }
}

- (void)testReplasment
{
   
    NSMutableArray *people = [NSMutableArray array];
    dispatch_queue_t testQueuse = dispatch_queue_create("com.tst.test", DISPATCH_QUEUE_SERIAL);
    dispatch_apply(10, testQueuse, ^(size_t idx) {
        TSTPerson *testPerson = [TSTPerson new];
        testPerson.firstName = [NSString stringWithFormat:@"TEST %zu",idx];
        [people addObject:testPerson];
    });
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)];
    [self.dataProvider replaceObjectsAtIndexes:indexes withObjects:people];
    
    NSDate *finish = [NSDate dateWithTimeIntervalSinceNow:10];
    
    while (self.didChangeCount != 1 && [[finish laterDate:[NSDate date]] isEqualToDate:finish]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    XCTAssertTrue(self.willChangeCount == 1);
    XCTAssertTrue(self.didChangeCount == 1);
    XCTAssertTrue([self.changes count] == 20);
    
}


- (void)observableObjectWillChangeContent:(id <TSTObservable>)observable userInfo:(NSMutableDictionary *)userInfo
{
    self.willChangeCount += 1;
}

- (void)observableObject:(id <TSTObservable>)observable didChangeObject:(id)anObject atIndex:(NSUInteger)index1 forChangeType:(TSTListenerChangeType)type userInfo:(NSMutableDictionary *)userInfo
{
    [self.changes addObject:anObject];
}

- (void)observableObjectDidChangeContent:(id <TSTObservable>)observable userInfo:(NSMutableDictionary *)userInfo
{
    self.didChangeCount += 1;
}

@end
