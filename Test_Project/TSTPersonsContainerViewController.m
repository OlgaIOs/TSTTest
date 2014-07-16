//
//  TSTTransitionViewController.m
//  Test_Project
//
//  Created by Sergey Kovalenko on 7/9/14.
//  Copyright (c) 2014 Anton Kuznetsov. All rights reserved.
//

#import "TSTPersonsContainerViewController.h"

static const NSTimeInterval TSTAnimationDuration = 0.3;

@interface TSTPersonsContainerViewController ()

@property (nonatomic, strong) NSMutableDictionary *viewControllers;
@property (nonatomic, readwrite) UIViewController *contentController;

@end

@interface TSTTransitionSegue : UIStoryboardSegue

@end

@implementation TSTTransitionSegue

- (void)perform {
    UIViewController *destinationViewController = self.destinationViewController;
    TSTPersonsContainerViewController *sourceViewController = self.sourceViewController;
    [sourceViewController registerViewController:destinationViewController
                         forInterfaceOrientationMask:destinationViewController.supportedInterfaceOrientations];
}

@end

@implementation TSTPersonsContainerViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _viewControllers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self performSegueWithIdentifier:@"TSTTransitionSegue" sender:nil];
    [self performSegueWithIdentifier:@"TSTTransitionSegue2" sender:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateContentForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] animated:animated];
}

#pragma mark - Interface orientation methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger supportedInterfaceOrientationsMask = 0;
    for (NSNumber *orientation in [self.viewControllers allKeys]) {
        supportedInterfaceOrientationsMask |= 1 << orientation.unsignedIntegerValue;
    }
    return supportedInterfaceOrientationsMask;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration; {
    
    [self updateContentForInterfaceOrientation:toInterfaceOrientation animated:YES];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

}

#pragma mark - Transitions methods
- (void)transitionToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController  withOptions:(UIViewAnimationOptions)options animated:(BOOL)animated {
    
    UIViewAnimationOptions animationOptions = options |
    UIViewAnimationOptionLayoutSubviews |
    UIViewAnimationOptionAllowAnimatedContent |
    UIViewAnimationOptionOverrideInheritedOptions;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    toViewController.view.frame = self.view.bounds;
    toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    fromViewController.view.frame = self.view.bounds;
    fromViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    __weak TSTPersonsContainerViewController *weakSelf = self;
    void(^completion)(BOOL finished) = ^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        self.navigationItem.rightBarButtonItem = toViewController.navigationItem.rightBarButtonItem;
    };
    
    if (animated) {
        if (fromViewController) {

            [UIView transitionFromView:fromViewController.view
                                toView:toViewController.view
                              duration:TSTAnimationDuration
                               options:animationOptions
                            completion:completion];
            
        }
        else {
            
            [UIView transitionWithView:self.view
                              duration:TSTAnimationDuration
                               options:animationOptions
                            animations:^{
                                [self.view addSubview:toViewController.view];
                            } completion:completion];
        }
    }
    else {
        [fromViewController.view removeFromSuperview];
        [self.view addSubview:toViewController.view];
        completion(YES);
    }
}

- (void)updateContentForInterfaceOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    
    UIViewController *controller = [self registeredViewControllerForInterfaceOrientation:orientation];
    if (controller && self.contentController != controller) {
        [self transitionToViewController:controller fromViewController:self.contentController withOptions:UIViewAnimationOptionTransitionCrossDissolve animated:YES];
        self.contentController = controller;
    }
}

- (void)registerViewController:(UIViewController *)viewController forInterfaceOrientationMask:(NSUInteger)orientationMask {
    
    if ((orientationMask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        self.viewControllers[@(UIInterfaceOrientationPortrait)] = viewController;
    }
    
    if ((orientationMask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        self.viewControllers[@(UIInterfaceOrientationLandscapeLeft)] = viewController;
    }
    
    if ((orientationMask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        self.viewControllers[@(UIInterfaceOrientationLandscapeRight)] = viewController;
    }
    
    if ((orientationMask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        self.viewControllers[@(UIInterfaceOrientationPortraitUpsideDown)] = viewController;
    }
}

- (UIViewController *)registeredViewControllerForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return self.viewControllers[@(orientation)];
}

@end
