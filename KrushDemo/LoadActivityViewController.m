//
//  LoadActivityViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 9/3/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "LoadActivityViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface LoadActivityViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UIView *activityView;

@end

@implementation LoadActivityViewController

-(void)setLoadingMessage:(NSString *)loadingMessage{
    
   
    
    _loadingMessage = loadingMessage;
    self.loadingLabel.text = loadingMessage;
    
    [self.view layoutIfNeeded];
    [self.activityView layoutSubviews];
    
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    
    [_loadingLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
        
    if (_loadingMessage) {
        self.loadingLabel.text = _loadingMessage;
    }
    [_activity startAnimating];
    [_activityView setClipsToBounds:YES];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGRect bound                        = _activityView.bounds;
    UIBezierPath *bPath                 = [UIBezierPath bezierPathWithRect:bound];
    _activityView.layer.cornerRadius    = 5;
    _activityView.layer.shadowPath      = bPath.CGPath;
    _activityView.layer.shadowOpacity   = 1.f;
    _activityView.layer.shadowRadius    = 4;
    _activityView.layer.shadowColor     = [UIColor blackColor].CGColor;
    _activityView.layer.masksToBounds   = YES;
}

@end
