//
//  ExternalSignInDataEntryViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 9/9/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "ExternalSignInDataEntryViewController.h"
#import "UserData.h"
#import "NSString+Addition.h"

@interface ExternalSignInDataEntryViewController ()<UITextFieldDelegate>{
    UserData *editableUserData;
    BOOL submittedData;
}
@property (nonatomic, strong) UITextField *focusedTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *genderTextField;
@property (strong, nonatomic) IBOutlet UITextField *dobTextField;

@property (strong, nonatomic) IBOutlet UIButton *signInDataButton;

@end

@implementation ExternalSignInDataEntryViewController

//*****************************************************
#pragma mark - Private methods
//*****************************************************

-(void)loadFormWithData{
    if (!editableUserData) {
        editableUserData = [_userData copy];
    }
    
    _emailTextField.text        = _userData.emailID;
    _firstNameField.text        = _userData.firstName;
    _lastNameField.text         = _userData.lastName;
    _phoneNumberTextField.text  = _userData.gender;
    _dobTextField.text          = _userData.dobString;

    [_emailTextField        setEnabled:(_emailTextField.text.length == 0)];
    [_firstNameField        setEnabled:(_firstNameField.text.length == 0)];
    [_lastNameField         setEnabled:(_lastNameField.text.length == 0)];
    [_phoneNumberTextField  setEnabled:(_phoneNumberTextField.text.length == 0)];
    [_dobTextField          setEnabled:(_dobTextField.text.length == 0)];

}

-(void )focusNextTextFieldForTextField:(UITextField *)textField{
    if (textField == _emailTextField) {
        [_firstNameField becomeFirstResponder];
    }else if (textField == _firstNameField) {
        [_lastNameField becomeFirstResponder];
    } else if(textField == _lastNameField) {
        [_phoneNumberTextField becomeFirstResponder];
    } else if(textField == _phoneNumberTextField){
        [_genderTextField becomeFirstResponder];
    } else if(textField == _genderTextField){
        [_dobTextField becomeFirstResponder];
    } else {
        [_focusedTextField resignFirstResponder];
    }
}

-(void )focusNextTextField{
    [self focusNextTextFieldForTextField:_focusedTextField];
}

-(BOOL) doesTextFieldContainValidData:(UITextField *)textField{
    BOOL containValidData = YES;
    if (textField == _emailTextField) {
        containValidData = [_emailTextField.text isAValidEmailID];
    }else if (textField == _firstNameField) {
        containValidData = [_firstNameField.text isAValidName];
    } else if(textField == _lastNameField) {
        containValidData = [_lastNameField.text isAValidName];
    } else if(textField == _phoneNumberTextField){
    } else if(textField == _genderTextField){
    } else if(textField == _dobTextField){}
    return containValidData;
}

-(BOOL)canTextFieldReturn:(UITextField *)textField{
    BOOL canReturn = [self doesTextFieldContainValidData:textField];
    return canReturn;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController) {
        if (!submittedData) {
            if (_userData.signInMethod == UserSignInMethod_Facebook) {
                [[FacebookHelper sharedInstance] closeLoginSession];
            }
        }
    }
}

//*****************************************************
#pragma mark - IBActions
//*****************************************************
- (IBAction)signInDataButton:(UIButton *)sender {
    
    submittedData = YES;
}


//*****************************************************
#pragma mark - Life cycle
//*****************************************************

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // Enable bounce for scrollview irrespective of content size
    [_scrollView setAlwaysBounceVertical:YES];
    
    [self loadFormWithData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


//*****************************************************
#pragma mark - TextField
//*****************************************************

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    // Ensure valid data provided by external service is not editable
    BOOL shouldBeginEditing = YES;
    
    if (textField == _emailTextField) {
        shouldBeginEditing = ![_userData.emailID isAValidEmailID];
    }else if(textField == _firstNameField) {
        shouldBeginEditing = ![_userData.firstName isAValidName];
    } else if (textField == _lastNameField) {
        shouldBeginEditing = ![_userData.lastName isAValidName];
    } else if (textField == _dobTextField) {
        shouldBeginEditing = _userData.dobString.length == 0;
    } else if (textField == _phoneNumberTextField) {
        shouldBeginEditing = _userData.phoneNumber.length == 0;
    }
    
    if (!shouldBeginEditing) {
        [self focusNextTextFieldForTextField:textField];
    }
    
    return shouldBeginEditing;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    BOOL canReturn = [self canTextFieldReturn:textField];
    return canReturn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.focusedTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.focusedTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    BOOL canReturn = [self canTextFieldReturn:textField];
    if (canReturn) {
        [self focusNextTextField];
    }
    return canReturn;
}
@end
