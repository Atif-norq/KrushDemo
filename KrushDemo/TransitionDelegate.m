//
//  TransitionDelegate.m
//  KrushDemo
//
//  Created by Atif Khan on 9/3/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "TransitionDelegate.h"

@implementation TransitionDelegate{
    BOOL ispresenting;
}

//*****************************************************
#pragma mark - Transition Delegate
//*****************************************************

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    ispresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
   
    ispresenting = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return .5;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *containerView = [transitionContext containerView];
    UIView *fromView        = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    UIView *toView          = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;

    fromView.frame = toView.frame = [containerView bounds];
    if (ispresenting) {
        [containerView insertSubview:fromView atIndex:0];
        [containerView insertSubview:toView atIndex:1];
        toView.alpha = 0;
    }else{
        [containerView insertSubview:toView atIndex:0];
        [containerView insertSubview:fromView atIndex:1];
    }
    
    float duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.8 initialSpringVelocity:7 options:0 animations:^{
        if (ispresenting) {
            toView.alpha = 1;
        }else{
            fromView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (!ispresenting) {
            [fromView removeFromSuperview];
        }
        [transitionContext completeTransition:YES];
    }];
    
}

@end
