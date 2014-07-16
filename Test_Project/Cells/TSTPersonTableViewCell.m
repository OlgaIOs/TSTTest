//
//  TSTPersonTableViewCell.m
//  Test_Project
//
//  Created by Yury Grinenko on 12.07.14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTPersonTableViewCell.h"
#import "TSTPerson.h"

@interface TSTPersonTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *personNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *personBirthDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *personPhotoImageView;

@end

@implementation TSTPersonTableViewCell

- (void)setupWithPerson:(TSTPerson *)person {
    [self.personNameLabel setText:person.fullName];
    [self.personBirthDateLabel setText:[NSDateFormatter localizedStringFromDate:person.birthDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
    [self.personPhotoImageView setImage:person.photo];
}

@end





