//
//  TSTGalleryViewController.m
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/15/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTGalleryViewController.h"
#import "TSTPhotoProvider.h"
#import "TSTListsViewMediator.h"

@interface TSTGalleryViewController ()
@property (nonatomic, strong) TSTPhotoProvider *provider;
@property (nonatomic, strong) TSTListsViewMediator *collectionViewMediator;

@end

@implementation TSTGalleryViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _provider = [[TSTPhotoProvider alloc] init];
        _collectionViewMediator = [[TSTListsViewMediator alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_provider removeListener:_collectionViewMediator];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionViewMediator.collectionView = self.collectionView;
    [self.provider addListener:self.collectionViewMediator];
    [self.provider fetchNextPage];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.provider count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:123];
    imageView.image = nil;
    [self.provider imageForIndex:indexPath.item
                associatedObject:cell
                       withBlock:^(UIImage *image) {
                           imageView.image = image;
                       }];
    
    if (indexPath.item == self.provider.count - 1){
        [self.provider fetchNextPage];
    }
    
    return cell;
}

@end
