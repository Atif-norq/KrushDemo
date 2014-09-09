//
//  SignInWithEmailViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 8/31/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "SignInWithEmailViewController.h"
#import "LoadActivityViewController.h"
#import "RefreshTokenScreenViewController.h"

#import "TransitionDelegate.h"
#import "UserSessionManager.h"

#import "NSString+Addition.h"

typedef enum {
    AlertType_RetrySignIn,
    AlertType_SignInComplete
}AlertType;

@interface SignInWithEmailViewController ()<UITextFieldDelegate, UserSignInDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) IBOutlet UITextField *userIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIButton *createProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, strong) LoadActivityViewController *signInLoadinActivity;
@property (nonatomic, strong) TransitionDelegate *transitionDelegate;
@end

@implementation SignInWithEmailViewController

-(BOOL )isLoginDataComplete{
    if ([_userIDTextField.text isAValidEmailID] && [_passwordField.text isAvalidPasswordForMobileUser]) {
        return YES;
    }
    return NO;
}

/// Private method
-(void )addGradientOverlayLayer{
    CAGradientLayer *layer = [CAGradientLayer layer];
    self.gradientLayer  = layer;
    layer.startPoint    = CGPointMake(.5, 0.f);
    layer.endPoint      = CGPointMake(.5f, 1.f);
    layer.colors        = @[    (id)[getColorForRGBA(30, 176, 245, 1.) CGColor],
                                (id)[getColorForRGBA(24,137,199, 1.) CGColor]];
    [self.view.layer insertSublayer:layer atIndex:0];
}

// VC call backs
-(void)viewDidLoad{
    [super viewDidLoad];
    self.transitionDelegate = [TransitionDelegate new];
    [UserSessionManager sharedInstance].signindelegate = self;
    
    self.view.backgroundColor = getColorForRGBA(30, 176, 245, 1.);
    
    _signInButton.titleLabel.font = [FontHelper fontProximaBoldSize:22];
    _forgotPasswordButton.titleLabel.font = _createProfileButton.titleLabel.font = [FontHelper fontProximaBoldSize:17];
    
    // Add gradient overlay layer
    [self addGradientOverlayLayer];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIImage *backArrow = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.navigationController.navigationBar setBackIndicatorImage:backArrow];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:backArrow];
    
    UIFont *textFieldFont = [FontHelper fontProximaLightSize:18];
    _userIDTextField.font = _passwordField.font = textFieldFont;
    
    _userIDTextField.attributedPlaceholder = [@"Email (or Username)" attrMStringWithFont:textFieldFont alignment:NSTextAlignmentLeft color:[UIColor lightTextColor]];
    _passwordField.attributedPlaceholder = [@"Password" attrMStringWithFont:textFieldFont alignment:NSTextAlignmentLeft color:[UIColor lightTextColor]];

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UserSessionManager sharedInstance].signindelegate = self;

    self.title = @"Sign In With Email";
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _passwordField) {
        if (![_passwordField.text isAvalidPasswordForMobileUser]) {
            return NO;
        }
        [_passwordField resignFirstResponder];
        
        if ([self isLoginDataComplete]) {
            [self signInButtonClicked:nil];
        }
    }else if(textField == _userIDTextField){
        [_passwordField becomeFirstResponder];
    }
    return YES;
}

- (IBAction)resignKeyboard:(id)sender {
    [_passwordField resignFirstResponder];
    [_userIDTextField resignFirstResponder];
}

- (IBAction)signInButtonClicked:(id)sender {
    
    NSString*emailID = _userIDTextField.text;
    NSString *password = _passwordField.text;
    
    if ([emailID isAValidEmailID] && [password isAvalidPasswordForMobileUser]) {
        UserData *uData = [UserData new];
        uData.emailID = emailID;
        uData.password  = password;
        
        self.signInLoadinActivity = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadActivityViewController"];
        _signInLoadinActivity.loadingMessage = @"Signing In...";
        _signInLoadinActivity.modalPresentationStyle = UIModalPresentationCustom;
        _signInLoadinActivity.transitioningDelegate = _transitionDelegate;
        [self presentViewController:_signInLoadinActivity animated:YES completion:^{
            [[UserSessionManager sharedInstance] signInWithSignInData:uData];
        }];
    }else {
        if (![emailID isAValidEmailID]) {
            [_userIDTextField becomeFirstResponder];
        }else if(![password isAvalidPasswordForMobileUser]){
            [_passwordField becomeFirstResponder];
        }
    }
}

//*****************************************************
#pragma mark - Alert View Delegate
//*****************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == AlertType_SignInComplete) {
        
        RefreshTokenScreenViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RefreshTokenScreenViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if(alertView.tag == AlertType_RetrySignIn)
    {
        if (buttonIndex == 0) {
            // Cancel
            [_signInLoadinActivity dismissViewControllerAnimated:YES completion:NULL];
            self.signInLoadinActivity = nil;
        }else {
            // Retry
            UserData *uData = [UserData new];
            uData.emailID = _userIDTextField.text;
            uData.password  = _passwordField.text;
            [[UserSessionManager sharedInstance] signInWithSignInData:uData];
            
        }
    }
    
}

//*****************************************************
#pragma mark - Sign In Delegate
//*****************************************************

-(void )sessionManager:(UserSessionManager *)sessionManager signInCompleteWithNetworkError:(NSError *)error nativeErrorCode:(SessionErrorCode )errorCode forUser:(UserData *)user{
    
    switch (errorCode) {
        case SessionErrorCode_NoError:
        {
            [_signInLoadinActivity dismissViewControllerAnimated:YES completion:NULL];
            self.signInLoadinActivity = nil;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign-in complete" message:@"Successfully signed in" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            alert.tag = AlertType_SignInComplete;
            [alert show];
        }
            break;
        
        case SessionErrorCode_NetworkError:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign-in failed" message:@"Unable to connect to server. Please check your internet connection." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Re-try", nil];
            alert.tag = AlertType_RetrySignIn;
            [alert show];
        }
            break;
        
        case SessionErrorCode_WrongEmailPassword:
        default:
        {
            [[[UIAlertView alloc] initWithTitle:@"Sign-in failed" message:@"Wrong username/password" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
            [_signInLoadinActivity dismissViewControllerAnimated:YES completion:NULL];
            self.signInLoadinActivity = nil;
        }
            break;
    }
}

@end
