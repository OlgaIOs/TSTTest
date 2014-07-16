//
//  TSTPhotoProvider.h
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/15/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSTObservable.h"

extern const NSUInteger TSTPhotoProviderDefaultPageSize;

@interface TSTPhotoProvider : TSTObservable

- (id)initWithPageSize:(NSUInteger)pageSize;

- (void)fetchNextPage;
- (void)imageForIndex:(NSUInteger)idx associatedObject:(id)object withBlock:(void (^)(UIImage *image))fetchBlock;
- (NSUInteger)count;
@end
