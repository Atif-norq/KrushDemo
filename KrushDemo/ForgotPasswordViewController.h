//
//  ForgotPasswordViewController.h
//  KrushDemo
//
//  Created by Atif Khan on 8/31/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "BaseViewController.h"

@interface ForgotPasswordViewController : BaseViewController

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;

- (IBAction)sendForgetPassword:(id)sender;

@end
