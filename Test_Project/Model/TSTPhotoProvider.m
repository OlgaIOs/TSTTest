//
//  TSTPhotoProvider.m
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/15/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTPhotoProvider.h"
#import "TSTDataProvider.h"
#import <FlickrKit/FlickrKit.h>
#import "TSTObservable+Protected.h"
#import "FKDUDefaultDiskCache.h"
#import "FKUtilities.h"
#import "FKDUNetworkOperation.h"
#import <objc/runtime.h>

const NSUInteger TSTPhotoProviderDefaultPageSize = 100;

@interface TSTPhotoProvider () <TSTListener>
@property (nonatomic, strong) TSTDataProvider *dataProvider;
@property (nonatomic, strong) FKFlickrInterestingnessGetList *photoRequest;

@end

@implementation TSTPhotoProvider


- (id)init {
    return [self initWithPageSize:TSTPhotoProviderDefaultPageSize];
}

- (id)initWithPageSize:(NSUInteger)pageSize
{
    NSParameterAssert(pageSize > 0);
    
    self = [super init];
    if (self)
    {
        _photoRequest = [[FKFlickrInterestingnessGetList alloc] init];
        _photoRequest.per_page = [NSString stringWithFormat:@"%lu", (unsigned long)pageSize];
        
        _dataProvider = [[TSTDataProvider alloc] init];
        [_dataProvider addListener:self];
        
        [[FlickrKit sharedFlickrKit] initializeWithAPIKey:@"e3a39f9c4e7742df690a93e1d8d28803" sharedSecret:@"33603bd983c74c40"];
    }
    return self;
}

#pragma mark - Public Methods

- (NSUInteger)count {
    return self.dataProvider.count;
}

- (void)fetchNextPage {
    
    FlickrKit *fk = [FlickrKit sharedFlickrKit];
    
    __weak typeof(self) weakSelf = self;

    self.photoRequest.page = [NSString stringWithFormat:@"%lu", (unsigned long)[self nextPage]];
    
    [fk call:self.photoRequest completion:^(NSDictionary *response, NSError *error) {
        // Note this is not the main thread!
        if (response) {
            NSMutableArray *photoURLs = [NSMutableArray array];
            for (NSDictionary *photoData in [response valueForKeyPath:@"photos.photo"]) {
                NSURL *url = [fk photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:photoData];
                [photoURLs addObject:url];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // Any GUI related operations here
                [weakSelf.dataProvider addObjectsFromArray:photoURLs];
                
            });
        }
    }];
}

- (FKDUNetworkOperation *)associatedOperationForObject:(id)object
{
    return objc_getAssociatedObject(object, @selector(associatedOperationForObject:));
}

- (void)setAssociatedOperation:(FKDUNetworkOperation *)operation forObject:(id)object
{
    objc_setAssociatedObject(object, @selector(associatedOperationForObject:), operation, OBJC_ASSOCIATION_RETAIN);
}

- (void)imageForIndex:(NSUInteger)idx associatedObject:(id)object withBlock:(void (^)(UIImage *image))fetchBlock
{
    if (fetchBlock) {
        NSURL *photoURL = [self.dataProvider objectAtIndex:idx];
        
        dispatch_queue_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(downloadQueue, ^{
            
            FKDUNetworkOperation *previousOperation = [self associatedOperationForObject:object];
            if (previousOperation && ![previousOperation.request.URL isEqual:photoURL]) {
                [previousOperation cancel];
                [self setAssociatedOperation:nil forObject:object];
            }
            
            NSString *key = FKMD5FromString(photoURL.absoluteString);
            
            NSData *data = [[FKDUDefaultDiskCache sharedDiskCache] dataForKey:key maxAgeMinutes:FKDUMaxAgeInfinite];
            
            void(^notifyBlock)(NSData *) = ^(NSData *imageData) {
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    fetchBlock(image);
                });
            };
            
            if (!data) {
                FKDUNetworkOperation *imageOperation = [[FKDUNetworkOperation alloc] initWithURL:photoURL];
                [imageOperation sendAsyncRequestOnCompletion:^(NSURLResponse *response, NSData *data, NSError *error) {
                    dispatch_async(downloadQueue, ^{
                        [[FKDUDefaultDiskCache sharedDiskCache] storeData:data forKey:key];
                    });
                    notifyBlock(data);
                }];
                
                [self setAssociatedOperation:imageOperation forObject:object];
            } else {
                
                [self setAssociatedOperation:nil forObject:object];
                notifyBlock(data);
            }
        });
    }
}

#pragma mark - Private Methods

- (NSUInteger)nextPage
{
    NSUInteger currentPage = self.dataProvider.count / self.photoRequest.per_page.integerValue;
    return ++currentPage;
}

#pragma mark - TSTListener

- (void)observableObjectWillChangeContent:(id <TSTObservable>)observable userInfo:(NSMutableDictionary *)userInfo
{
    [self notifyWillChangeContent:userInfo];
}

- (void)observableObject:(id <TSTObservable>)observable didChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(TSTListenerChangeType)type userInfo:(NSMutableDictionary *)userInfo {
    [self notifyDidChangeObject:anObject atIndex:index forChangeType:type userInfo:userInfo];
}
- (void)observableObjectDidChangeContent:(id <TSTObservable>)observable userInfo:(NSMutableDictionary *)userInfo
{
    [self notifyDidChangeContent:userInfo];
}

@end
