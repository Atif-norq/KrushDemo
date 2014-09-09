//
//  SignUpViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 8/31/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "SignUpViewController.h"
#import "LoadActivityViewController.h"
#import "UserSessionManager.h"
#import "NSString+AttributedFormatedString.h"
#import "NSString+Addition.h"
#import "UserData.h"
#import "TransitionDelegate.h"
#import "GenderPickerDelegate.h"
#import "PickerContainerView.h"

typedef enum {
    ValidationWarning_DoNothing = 0,
    ValidationWarning_FNameEmpty = 1,
    ValidationWarning_LNameEmpty,
    ValidationWarning_EmailWrong,
    ValidationWarning_PasswordInvalid,
    ValidationWarning_ConfirmPasswordNotMatch
}ValidationWarning;

typedef enum {
    AlertType_Retry,
    AlertType_SomeErrorOccured,
    AlertType_Success
}AlertType;

@interface SignUpViewController ()<UserSignUpDelegate, UIAlertViewDelegate, GenderPickerSelectionProtocol>
@property (nonatomic, strong) GenderPickerDelegate *genderDataSource;
@property (nonatomic, strong) TransitionDelegate *transition;
@property (strong, nonatomic) IBOutlet UITextField *userIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *genderTextField;
@property (strong, nonatomic) IBOutlet UITextField *dobTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordConfirmTextfield;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) UITextField *focusedTextField;
@property (nonatomic, strong) LoadActivityViewController *loadingActivity;
@property (nonatomic, assign) Gender selectedGender;
@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation SignUpViewController

//*****************************************************
#pragma mark - VC private
//*****************************************************

-(NSString *)dateStringForDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd yyyy"];
    return [formatter stringFromDate:date];
}

-(void) setImage:(UIImage *)image inTextFieldAtRightSide:(UITextField *)textField mode:(UITextFieldViewMode) mode action:(ValidationWarning )action{
    
    if (image) {
        [textField setRightViewMode:mode];
        if (![textField.rightView isKindOfClass:[UIButton class]]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = action;
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(formTextFieldValidationFailedWaringButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            button.alpha = 0;
            button.frame = (CGRect){0,0, image.size};
            [textField setRightView:button];
            [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.75 initialSpringVelocity:7 options:0 animations:^{
                button.alpha = 1;
            } completion:NULL];
        }else{
            UIButton *button = (UIButton *)textField.rightView;
            button.tag = action;
            [button setImage:image forState:UIControlStateNormal];
            button.alpha = 1;

        }
        
        
    }else{
        [textField setRightView:nil];
        [textField setRightViewMode:UITextFieldViewModeNever];
    }
}

-(void )setImage:(UIImage *)image returnTextFieldAtRightSide:(UITextField *)textField action:(ValidationWarning )action
{
    [self setImage:image inTextFieldAtRightSide:textField mode:UITextFieldViewModeWhileEditing action:action];
}

-(void )setPlaceholderText:(NSString *)text inTextField:(UITextField *)textField{
    textField.attributedPlaceholder = [text attrMStringWithFont:[UIFont systemFontOfSize:16] alignment:NSTextAlignmentLeft color:[UIColor lightTextColor]];
}

-(BOOL )validateForm{
    BOOL pass = YES;
    UIImage *warningImage = [UIImage imageNamed:@"warning_30"];
    if (![self.emailTextField.text isAValidEmailID]) {
        pass = NO;
        [self setImage:warningImage inTextFieldAtRightSide:_emailTextField mode:UITextFieldViewModeAlways action:ValidationWarning_EmailWrong];
    }
    
    if (![self.passwordTextField.text isAvalidPasswordForMobileUser]) {
        pass = NO;
        [self setImage:warningImage inTextFieldAtRightSide:_passwordTextField mode:UITextFieldViewModeAlways action:ValidationWarning_PasswordInvalid];
    }else{
        if (![self.passwordTextField.text isEqualToString:self.passwordConfirmTextfield.text]) {
            pass = NO;
            [self setImage:warningImage inTextFieldAtRightSide:_passwordTextField mode:UITextFieldViewModeAlways action:ValidationWarning_ConfirmPasswordNotMatch];
        }
    }
    
    if (![_firstNameTextField.text isAValidName]) {
        pass = NO;
        [self setImage:warningImage inTextFieldAtRightSide:_firstNameTextField mode:UITextFieldViewModeAlways action:ValidationWarning_FNameEmpty];
    }
    
    if (![_lastNameTextField.text isAValidName]) {
        pass = NO;
        [self setImage:warningImage inTextFieldAtRightSide:_lastNameTextField mode:UITextFieldViewModeAlways action:ValidationWarning_LNameEmpty];
    }
    
    return pass;
}

//*****************************************************
#pragma mark - VC call backs
//*****************************************************
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Fill out a few quick details";
    [_userIDTextField becomeFirstResponder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [UserSessionManager sharedInstance].signupdelegate = self;
    
    self.transition                 = [TransitionDelegate new];
    _submitButton.titleLabel.font   = [FontHelper fontProximaBoldSize:22];
    
    self.title = @"Fill out a few quick details";
    [self setPlaceholderText:@"Email (or username)"     inTextField:_userIDTextField];
    [self setPlaceholderText:@"Email"                   inTextField:_emailTextField];
    [self setPlaceholderText:@"First name"              inTextField:_firstNameTextField];
    [self setPlaceholderText:@"Last name"               inTextField:_lastNameTextField];
    
    [self setPlaceholderText:@"Phone number"        inTextField:_phoneNumberTextField];
    [self setPlaceholderText:@"Gender"              inTextField:_genderTextField];
    [self setPlaceholderText:@"Date of Birth"       inTextField:_dobTextField];

    [self setPlaceholderText:@"Password"                inTextField:_passwordTextField];
    [self setPlaceholderText:@"Confirm Password"        inTextField:_passwordConfirmTextfield];
    

}

//*****************************************************
#pragma mark - Target
//*****************************************************

-(void )resignedFocusedTextField:(id )sender{
    [_focusedTextField resignFirstResponder];
}

-(void )goToNextTextField:(id )sender{
    
    if (_focusedTextField == _genderTextField) {
        [_dobTextField becomeFirstResponder];
    }else if(_focusedTextField == _dobTextField) {
        [_passwordTextField becomeFirstResponder];
    }
}

-(void )datePickerValueChanged:(UIDatePicker *)sender {
    
    self.selectedDate = sender.date;
    _dobTextField.text = [self dateStringForDate:_selectedDate];
}

//*****************************************************
#pragma mark - Keyboard targets
//*****************************************************

-(void )keyboardWillShow:(NSNotification *)notification
{
    self.keyboardVisible = YES;
    //nextButtonBottomConstraint

}

-(void )keyboardWillHide:(NSNotification *)notification
{
    self.keyboardVisible = NO;
}

-(void )keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottomMargin = self.view.bounds.size.height - keyboardRect.origin.y + _nextButtonHeightConstraint.constant - 2;
    float duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.95 initialSpringVelocity:9 options:0 animations:^{
        _nextButtonBottomConstraint.constant = bottomMargin;
        [self.view layoutSubviews];
    } completion:^(BOOL finished) {
        [self.view layoutIfNeeded];
    }];

    NSLog(@"%s\n\nMargin:%f",__func__, bottomMargin);

}

//*****************************************************
#pragma mark - Gender picker
//*****************************************************

-(void )pickerDataSource:(GenderPickerDelegate *)dataSource selectedGender:(Gender )gender{
    self.selectedGender = gender;
    _genderTextField.text = [GenderPickerDelegate genderDisplayStringForCode:gender];
}

//*****************************************************
#pragma mark - Textfield delegate
//*****************************************************

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _genderTextField) {
        PickerContainerView *container = [[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] lastObject];
        container.backgroundColor = [UIColor lightTextColor];
    
        [container.toolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(resignedFocusedTextField:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(goToNextTextField:)]]];
        UIPickerView *picker    = container.picker;
        picker.backgroundColor = [UIColor lightTextColor];
        textField.inputView = container;
        if (!_genderDataSource) {
            self.genderDataSource = [GenderPickerDelegate new];
            _genderDataSource.delegate = self;
        }
        [_genderDataSource reloadPicker:picker withSelectedGender:Gender_DontMention];
    }else if(textField == _dobTextField){
        PickerContainerView *container = [[[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil] lastObject];
        container.backgroundColor = [UIColor lightTextColor];
        container.cancelBarbutton.target = self;
        container.cancelBarbutton.action = @selector(resignedFocusedTextField:);
        container.nextBarButton.target = self;
        container.nextBarButton.action = @selector(goToNextTextField:);
        textField.inputView = container;
        [container.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self setImage:nil returnTextFieldAtRightSide:textField action:ValidationWarning_DoNothing];
    self.focusedTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.focusedTextField == textField) {
        self.focusedTextField = nil;
    }
    
    if (textField == _firstNameTextField || textField == _lastNameTextField){
        NSString *text = textField.text;
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        textField.text = text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if ((textField == _firstNameTextField || textField == _lastNameTextField) && string.length>0) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return [newString isAValidName];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _userIDTextField) {
        [_firstNameTextField becomeFirstResponder];
    }else if(textField == _firstNameTextField){
        if ([_firstNameTextField.text isAValidName]) {
            [_lastNameTextField becomeFirstResponder];
        }else {
            [self setImage:[UIImage imageNamed:@"warning_30"] returnTextFieldAtRightSide:_firstNameTextField action:ValidationWarning_FNameEmpty];
        }
    }else if(textField == _lastNameTextField){
        
        if ([_lastNameTextField.text isAValidName]) {
            [_phoneNumberTextField becomeFirstResponder];
        }else {
            [self setImage:[UIImage imageNamed:@"warning_30"] returnTextFieldAtRightSide:_lastNameTextField action:ValidationWarning_LNameEmpty];
        }
    }else if(textField == _phoneNumberTextField){
        [_genderTextField becomeFirstResponder];
    }else if(textField == _genderTextField){
        [_dobTextField becomeFirstResponder];
    }else if(textField == _dobTextField){
        [_passwordTextField becomeFirstResponder];
    }else if(textField == _emailTextField){
        if ([_emailTextField.text isAValidEmailID]) {
            [self setImage:nil returnTextFieldAtRightSide:_emailTextField action:ValidationWarning_EmailWrong];
            [_firstNameTextField becomeFirstResponder];
        }else{
            [self setImage:[UIImage imageNamed:@"warning_30"] returnTextFieldAtRightSide:_emailTextField action:ValidationWarning_EmailWrong];
            return NO;
        }
    }else if(textField == _passwordTextField){
        if ([_passwordTextField.text isAvalidPasswordForMobileUser]) {
            [self setImage:nil returnTextFieldAtRightSide:_passwordTextField action:ValidationWarning_DoNothing];
            [_passwordConfirmTextfield becomeFirstResponder];
        }else{
            [self setImage:[UIImage imageNamed:@"warning_30"] returnTextFieldAtRightSide:_passwordTextField action:ValidationWarning_PasswordInvalid];
            return NO;
        }
    }else if(textField == _passwordConfirmTextfield){
        if ([_passwordTextField.text isAvalidPasswordForMobileUser]) {
            if (![_passwordTextField.text isEqualToString:_passwordConfirmTextfield.text]) {
                [self setImage:[UIImage imageNamed:@"warning_30"] returnTextFieldAtRightSide:_passwordConfirmTextfield action:ValidationWarning_ConfirmPasswordNotMatch];
                return NO;
            }
        }else{
            [_passwordTextField becomeFirstResponder];
        }
        [textField resignFirstResponder];
    }
    return YES;
}

//*****************************************************
#pragma mark - IBAction
//*****************************************************

-(void )formTextFieldValidationFailedWaringButtonTapped:(UIButton *)sender{
    switch (sender.tag) {
        case ValidationWarning_EmailWrong:
            [[[UIAlertView alloc] initWithTitle:@"Please provide a valid Email ID." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            break;
            
        case ValidationWarning_PasswordInvalid:
            [[[UIAlertView alloc] initWithTitle:@"Password must be 6 character long"
                                        message:@"Note: Password is case sensitive"
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            break;
        
        case ValidationWarning_ConfirmPasswordNotMatch:
            [[[UIAlertView alloc] initWithTitle:@"Confirm password don't match with password. Please verify."
                                        message:@"Note: Password is case sensitive"
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil] show];
            break;
            
        case ValidationWarning_FNameEmpty:
            [[[UIAlertView alloc] initWithTitle:@"First name cannot be empty"
                                        message:@"Note: Password is case sensitive"
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil] show];
            break;
            
        case ValidationWarning_LNameEmpty:
            [[[UIAlertView alloc] initWithTitle:@"Last name cannot be empty"
                                        message:@"Note: Password is case sensitive"
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil] show];
            break;
        default:
            break;
        
    }
}

- (IBAction)createAProfile:(UIButton *)sender
{
    // Resign keyboard
    [_focusedTextField resignFirstResponder];
    
    // Check if user data is valid
    if ([self validateForm]) {
        // Call api to regiter user
       
        UserData *userData      = [UserData new];
        userData.firstName      = _firstNameTextField.text;
        userData.lastName       = _lastNameTextField.text;
        userData.password       = _passwordTextField.text;
        userData.emailID        = _emailTextField.text;
        userData.phoneNumber    = _phoneNumberTextField.text;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        userData.dobString      = [formatter stringFromDate:_selectedDate];
        userData.gender         = [GenderPickerDelegate genderDisplayStringForCode:_selectedGender];
        
        self.loadingActivity = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadActivityViewController"];
        self.loadingActivity.modalPresentationStyle = UIModalPresentationCustom;
        self.loadingActivity.transitioningDelegate = _transition;
        self.loadingActivity.loadingMessage = @"Creating your profile...";
        [self presentViewController:_loadingActivity animated:YES completion:^{
            [[UserSessionManager sharedInstance] signUpWithSignInData:userData];
        }];
        
        
    }
#ifdef DEBUG
    else{
        NSLog(@"%s Form valdiation failed",__func__);
    }
#endif

}

//*****************************************************
#pragma mark - Alert Delegate
//*****************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == AlertType_Success) {
        [self.navigationController popViewControllerAnimated:YES];
   
    }else if(alertView.tag == SessionErrorCode_NetworkError){
        if (buttonIndex == 1) {
            UserData *userData  = [UserData new];
            userData.firstName  = _firstNameTextField.text;
            userData.lastName   = _lastNameTextField.text;
            userData.password   = _passwordTextField.text;
            userData.emailID    = _emailTextField.text;
            [[UserSessionManager sharedInstance] signUpWithSignInData:userData];
        }else{
            [_loadingActivity dismissViewControllerAnimated:YES completion:NULL];
            self.loadingActivity = nil;
        }
        
        
    }
}

//*****************************************************
#pragma mark - Sign Up delegate
//*****************************************************

-(void )sessionManager:(UserSessionManager *)sessionManager signUpCompleteWithNetworkError:(NSError *)error nativeErrorCode:(SessionErrorCode )errorCode forUserData:(UserData *)user{
    
    if (errorCode == SessionErrorCode_NoError) {
        
        [_loadingActivity dismissViewControllerAnimated:YES completion:NULL];
        self.loadingActivity = nil;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Complete" message:@"You are successful signed up." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        alert.tag = AlertType_Success;
        [alert show];
        
    }else if (errorCode == SessionErrorCode_NetworkError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to reach internet" message:@"Please check your internet connection and re try." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Re try", nil];
        alert.tag = AlertType_Retry;
        [alert show];
    }else {
        NSString *title = @"Some error occured";
        if (errorCode == SessionErrorCode_WrongEmailPassword) {
            title = @"Wrong Email/Password";
        }
        [_loadingActivity dismissViewControllerAnimated:YES completion:NULL];
        self.loadingActivity = nil;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        alert.tag = AlertType_SomeErrorOccured;
        [alert show];
    }
}

@end
