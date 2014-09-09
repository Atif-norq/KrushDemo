//
//  ViewController.h
//  KrushDemo
//
//  Created by Atif Khan on 8/28/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "BaseViewController.h"
@interface ViewController : BaseViewController
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hSpacingFacebookButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hSpacingTwitterButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hSpacingEmailButton;
- (IBAction)goToDefaultState:(id)sender;

- (IBAction)signInWihtFacebook:(id)sender;
- (IBAction)signInWithGooglePlus:(id)sender;
@end
