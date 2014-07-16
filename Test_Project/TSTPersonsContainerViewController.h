//
//  TSTTransitionViewController.h
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/9/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSTPersonsContainerViewController : UIViewController

- (void)registerViewController:(UIViewController *)viewController forInterfaceOrientationMask:(NSUInteger)orientationMask;

- (UIViewController *)registeredViewControllerForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
