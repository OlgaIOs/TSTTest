//
//  TSTPersonCollectionViewCell.m
//  Test_Project
//
//  Created by Yury Grinenko on 12.07.14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTPersonCollectionViewCell.h"
#import "TSTPerson.h"

@interface TSTPersonCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *personPhotoImageView;

@end

@implementation TSTPersonCollectionViewCell

- (void)setupWithPerson:(TSTPerson *)person {
    [self.personPhotoImageView setImage:person.photo];
}


@end
