//
//  SignUpViewController.h
//  KrushDemo
//
//  Created by Atif Khan on 8/31/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "BaseViewController.h"

@interface SignUpViewController : BaseViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nextButtonHeightConstraint;

- (IBAction)createAProfile:(id)sender;
@end
