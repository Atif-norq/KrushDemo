//
//  UpdateProfileViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 9/7/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "UpdateProfileViewController.h"
#import "TextFieldTableViewCell.h"
#import "UserData.h"
#import "NSString+AttributedFormatedString.h"
#import "NSString+Addition.h"
#import "Downloader.h"
#import "UserSessionManager.h"
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
    ValidationType_NoValidation,
    ValidationType_Email,
    ValidationType_Name,
    ValidationType_Phone,
    ValidationType_Country,
    ValidationType_Gender,
    ValidationType_Dob,
}ValidationType;

typedef enum {
    CustomKeyboardType_NotCustom = 0,
    CustomKeyboardType_Gender =1,
    CustomKeyboardType_Date = 2
}CustomKeyboardType;


NSString *fieldFirstName    = @"First name";
NSString *fieldLastName     = @"Last name";
NSString *fieldPhoneNumber  = @"Phone number";
NSString *fieldCountry      = @"Country";
NSString *fieldGender       = @"Gender";
NSString *fieldDOB          = @"DOB";

NSString *fieldArgumentPlaceHolder          = @"placeholdertitle";
NSString *fieldArgumentValidationType       = @"validationtype";
NSString *fieldArgumentKeyboardType         = @"keyboardtype";
NSString *fieldArgumentIsSecure             = @"isSecure";
NSString *fieldArgumentCustomKeyboardType   = @"customKeyboardType";


@interface UpdateProfileViewController ()<UITextFieldDelegate, DownloaderResponseDelegate, DownloaderResponseDelegate, UIAlertViewDelegate, GenderPickerSelectionProtocol>
@property (nonatomic, assign) BOOL disableEditing;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) GenderPickerDelegate *genderPickerDelegate;
@property (nonatomic, strong) UserData *userData;
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSMutableDictionary *fieldsValue;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *loadingActivityContainer;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;
@property (nonatomic, strong) Downloader *getProfileConnection;
@property (nonatomic, strong) Downloader *updateProfileConnection;

@property (nonatomic, strong) UITextField *focusedTextField;

@property (nonatomic, strong) NSDate *selectedDOB;
@property (nonatomic, assign) Gender currentGender;
@end

@implementation UpdateProfileViewController


-(NSString *)dateStringForDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd yyyy"];
    return [formatter stringFromDate:date];
}

-(NSDate *)serverDateForProfileUserDOB{
    if (_userData.dobString) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];//1988-07-05T00:00:00
        return [df dateFromString:_userData.dobString];
    }
    return nil;
}

-(NSString *)serverDateTextForDate:(NSDate *)date{
    if (_userData.dobString) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];//1988-07-05T00:00:00
        return [df stringFromDate:date];
    }
    return nil;
}

-(void )getUserProfile{
    [_getProfileConnection cancel];
    _loadingActivityContainer.alpha = 1;
    self.getProfileConnection = [[Downloader alloc] initWithRequest:[[UserSessionManager sharedInstance] requestForGetProfile] cachePolicy:NSURLRequestReloadIgnoringCacheData delegate:self autoStartEnabled:YES];
    _table.hidden = _updateButton.hidden = YES;
    _loadingActivityContainer.hidden = NO;
    [_activity startAnimating];
}

-(void) setImage:(UIImage *)image inTextFieldAtRightSide:(UITextField *)textField mode:(UITextFieldViewMode) mode action:(ValidationWarning )action{
    
    if (image) {
        [textField setRightViewMode:mode];
        if (![textField.rightView isKindOfClass:[UIButton class]]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = action;
            [button setImage:image forState:UIControlStateNormal];
           // [button addTarget:self action:@selector(formTextFieldValidationFailedWaringButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
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
    UIFont *font = [UIFont systemFontOfSize:16];
    textField.font = font;
    textField.attributedPlaceholder = [text attrMStringWithFont:font alignment:NSTextAlignmentLeft color:[UIColor lightTextColor]];
}

- (IBAction)updateProfile:(id)sender {
    [_focusedTextField resignFirstResponder];
    self.disableEditing = YES;
    
    _userData.dobString = [self serverDateTextForDate:_selectedDOB];
    self.updateProfileConnection = [[Downloader alloc] initWithRequest:[[UserSessionManager sharedInstance] authorizeUpdateRequestForUser:_userData] cachePolicy:NSURLRequestReloadIgnoringCacheData delegate:self autoStartEnabled:YES];
    _userData.dobString = [self dateStringForDate:_selectedDOB];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Update Profile";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (!_userData) {
        [self getUserProfile];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [_updateProfileConnection cancel];
        [_getProfileConnection cancel];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _table.hidden           = YES;
    _updateButton.hidden    = YES;
    
    self.fieldsValue = [NSMutableDictionary dictionary];
    self.view.backgroundColor = [UIColor colorWithRed:30/255. green:170/255.f blue:246/255. alpha:1.];
    self.fields = @[
                    @{fieldArgumentPlaceHolder: fieldFirstName,
                      fieldArgumentValidationType: @(ValidationType_Name),
                      fieldArgumentKeyboardType: @(UIKeyboardTypeAlphabet)},
                    
                    @{fieldArgumentPlaceHolder: fieldLastName,
                      fieldArgumentValidationType: @(ValidationType_Name),
                      fieldArgumentKeyboardType: @(UIKeyboardTypeAlphabet)},
                   
                    @{fieldArgumentPlaceHolder: fieldPhoneNumber,
                      fieldArgumentValidationType: @(ValidationType_Phone),
                      fieldArgumentKeyboardType: @(UIKeyboardTypePhonePad)},
                    
                    @{fieldArgumentPlaceHolder: fieldGender,
                      fieldArgumentValidationType: @(ValidationType_NoValidation),
                      fieldArgumentCustomKeyboardType:@(CustomKeyboardType_Gender)},
                    
                    @{fieldArgumentPlaceHolder: fieldDOB,
                      fieldArgumentValidationType: @(ValidationType_NoValidation),
                      fieldArgumentCustomKeyboardType:@(CustomKeyboardType_Date)}

                    ];
    
    // Hide table view and Update button till profile info will not be downloaded
    _table.hidden = _updateButton.hidden = YES;
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect bound                        = _loadingActivityContainer.bounds;
    UIBezierPath *bPath                 = [UIBezierPath bezierPathWithRect:bound];
    _loadingActivityContainer.layer.cornerRadius    = 5;
    _loadingActivityContainer.layer.shadowPath      = bPath.CGPath;
    _loadingActivityContainer.layer.shadowOpacity   = 1.f;
    _loadingActivityContainer.layer.shadowRadius    = 4;
    _loadingActivityContainer.layer.shadowColor     = [UIColor blackColor].CGColor;
    _loadingActivityContainer.layer.masksToBounds   = YES;
}

-(void )loadCell:(TextFieldTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *fieldArgument         = _fields[indexPath.row];
    cell.textfield.tag = indexPath.row;
    cell.textfield.keyboardAppearance   = UIKeyboardAppearanceDark;
    if (fieldArgument[fieldArgumentKeyboardType]) {
        cell.textfield.keyboardType         = [fieldArgument[fieldArgumentKeyboardType] intValue];
    }
    cell.textfield.returnKeyType        = (indexPath.row == (_fields.count-1))?UIReturnKeyGo:UIReturnKeyNext;
    
    NSString *placeHolder = fieldArgument[fieldArgumentPlaceHolder];
    
    if ([placeHolder isEqualToString:fieldFirstName]) {
        cell.textfield.text = _userData.firstName;
    }else if ([placeHolder isEqualToString:fieldLastName]) {
        cell.textfield.text = _userData.lastName;
    }else if ([placeHolder isEqualToString:fieldGender]) {
        cell.textfield.text = _userData.gender;
    }else if ([placeHolder isEqualToString:fieldCountry]) {
        cell.textfield.text = _userData.country;
        
    }else if ([placeHolder isEqualToString:fieldDOB]) {
        cell.textfield.text = _userData.dobString;
    }else if ([placeHolder isEqualToString:fieldPhoneNumber]) {
        cell.textfield.text = _userData.phoneNumber;
    }
    
    
    cell.textfield.delegate             = self;
    [self setPlaceholderText:fieldArgument[fieldArgumentPlaceHolder] inTextField:cell.textfield];

}

//*****************************************************

#pragma mark - Table DataSource

//*****************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    TextFieldTableViewCell *cell        = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [self loadCell:cell forIndexPath:indexPath];
    return cell;
}

//*****************************************************

#pragma mark - Table Delegate

//*****************************************************

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//*****************************************************
#pragma mark - Target
//*****************************************************

-(void )resignedFocusedTextField:(id )sender{
    [_focusedTextField resignFirstResponder];
}

-(void )goToNextTextField:(id )sender{
    UITextField *textField = _focusedTextField;
    
    if (textField.tag >= _fields.count) {
        [textField resignFirstResponder];
    }else{
        int newRow = textField.tag+1;
        [textField resignFirstResponder];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRow inSection:0];
        
        TextFieldTableViewCell *cell = (TextFieldTableViewCell *)[_table cellForRowAtIndexPath:indexPath];
        [cell.textfield becomeFirstResponder];
        
    }
    
}

-(void )datePickerValueChanged:(UIDatePicker *)picker{
    self.selectedDOB    = picker.date;
    _userData.dobString = [self dateStringForDate:_selectedDOB];
    
    if (_focusedTextField) {
        int row = _focusedTextField.tag;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self loadCell:(TextFieldTableViewCell *)[_table cellForRowAtIndexPath:indexPath] forIndexPath:indexPath];
    }
}

//*****************************************************
#pragma mark - Gender Delegate
//*****************************************************

-(void )pickerDataSource:(GenderPickerDelegate *)dataSource selectedGender:(Gender )gender{
    
    _userData.gender = [GenderPickerDelegate genderDisplayStringForCode:gender];
    
    if (_focusedTextField) {
        int row = _focusedTextField.tag;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        TextFieldTableViewCell *cell = (TextFieldTableViewCell *)[_table cellForRowAtIndexPath:indexPath];
        [self loadCell:cell forIndexPath:indexPath];
    }
}

//*****************************************************
#pragma mark - Text field
//*****************************************************

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    if (_disableEditing) {
        return NO;
    }
    
    NSDictionary *dict      = _fields[textField.tag];
    CustomKeyboardType ckType = [dict[fieldArgumentCustomKeyboardType] intValue];
    if (ckType == CustomKeyboardType_Gender) {
        if (!_genderPickerDelegate) {
            self.genderPickerDelegate = [GenderPickerDelegate new];
            _genderPickerDelegate.delegate = self;
        }
        PickerContainerView *container = [[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] lastObject];
        container.backgroundColor = [UIColor lightTextColor];
       
        [container.toolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(resignedFocusedTextField:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(goToNextTextField:)]]];

        
        UIPickerView *picker    = container.picker;
        picker.backgroundColor = [UIColor lightTextColor];
        textField.inputView = container;
        NSString *text = textField.text;
        
        [_genderPickerDelegate reloadPicker:picker withSelectedGender:(text.length > 0 ? ([text hasPrefix:@"M"]?Gender_Male:Gender_Female):Gender_DontMention)];
        
    } else if(ckType == CustomKeyboardType_Date){
        PickerContainerView *container = [[[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil] lastObject];
        container.backgroundColor = [UIColor lightTextColor];
        container.cancelBarbutton.target = self;
        container.cancelBarbutton.action = @selector(resignedFocusedTextField:);
        container.nextBarButton.target = self;
        container.nextBarButton.title = @"Done";
        container.nextBarButton.style = UIBarButtonItemStyleDone;
        container.nextBarButton.action = @selector(goToNextTextField:);
        textField.inputView = container;
        [container.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSDictionary *dict      = _fields[textField.tag];
    NSString *displayName   = dict[fieldArgumentPlaceHolder];
    
    if ([displayName isEqualToString:fieldFirstName]) {
        _userData.firstName = textField.text;
    }else if ([displayName isEqualToString:fieldLastName]) {
        _userData.lastName = textField.text;
    }else if ([displayName isEqualToString:fieldGender]) {
        _userData.gender = textField.text;
    }else if ([displayName isEqualToString:fieldCountry]) {
        
    }else if ([displayName isEqualToString:fieldDOB]) {
        _userData.dobString = textField.text;
    }else if ([displayName isEqualToString:fieldPhoneNumber]) {
        _userData.phoneNumber = textField.text;
    }
    
    self.focusedTextField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSDictionary *dict      = _fields[textField.tag];
    UIKeyboardType keyboardType = [dict[fieldArgumentKeyboardType] intValue];
    
    if (string.length>0) {
        if (keyboardType == UIKeyboardTypeASCIICapable) {
            
        }else if (keyboardType == UIKeyboardTypePhonePad){
            
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    
    NSDictionary *dict      = _fields[textField.tag];
    ValidationType validationType   = [[dict valueForKey:fieldArgumentValidationType] intValue];
    BOOL shouldReturn = YES;
    switch (validationType) {
        case ValidationType_Name:
            shouldReturn = [textField.text isAValidName];
            break;
            
        case ValidationType_Phone:
            
            break;
        
        default:
            shouldReturn = YES;
            break;
    }

    if (shouldReturn) {
        [self goToNextTextField:nil];
    }
    return shouldReturn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.focusedTextField = textField;
}

//*****************************************************
#pragma mark - Keyboard
//*****************************************************

-(void )keyboardWillShow:(NSNotification *)notification
{
    //nextButtonBottomConstraint
    
}

-(void )keyboardWillHide:(NSNotification *)notification
{
}

-(void )keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    CGRect keyboardRect = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottomMargin = self.view.bounds.size.height - keyboardRect.origin.y  ;
    float duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationCurve = [[info valueForKeyPath:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.95 initialSpringVelocity:9 options:animationCurve animations:^{
        _sendButtonBottomConstraint.constant = bottomMargin;
        [self.view layoutSubviews];
    } completion:^(BOOL finished) {
        [self.view layoutIfNeeded];
    }];
    
    NSLog(@"%s\n\nMargin:%f",__func__, bottomMargin);
}
//*****************************************************
#pragma mark - UIAlertView Delegate
//*****************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // Re try
        [self getProfileConnection];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//*****************************************************
#pragma mark - Downloader
//*****************************************************

-(void)downloader:(Downloader*)downloader
 errorDownloading:(NSError*)error{
    [[[UIAlertView alloc] initWithTitle:@"Unable to connnect to server"
                                message:error.localizedDescription
                               delegate:self cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Re try", nil] show];
}

-(void)downloader:(Downloader*)downloader dataDownloadedDownloadedForLink:(NSURL*)link{
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.75 initialSpringVelocity:8 options:0 animations:^{
        _loadingActivityContainer.alpha = 0;
    } completion:^(BOOL finished) {
        [_activity stopAnimating];
        _loadingActivityContainer.hidden = YES;
        _loadingActivityContainer.alpha = 1;
        
    }];
    
#ifdef DEBUG
    NSLog(@"%s, %@",__func__, [[NSString alloc] initWithData:downloader.mData encoding:NSUTF8StringEncoding]);
#endif
    // Check for valid response
    ApiResponseParser *parser = [[ApiResponseParser alloc] init];
    [parser parseData:downloader.mData networkStatusCode:downloader.networkStatusCode];
    
    if (downloader == _getProfileConnection) {
    
        // If valid profile is received show table and update button
        switch (parser.httpCode) {
            case HttpCode_Success:
            {
                self.userData = parser.profileUserData;
                self.selectedDOB = [self serverDateForProfileUserDOB];
                self.userData.dobString = [self dateStringForDate:_selectedDOB];
                
                [_table reloadData];
                _table.hidden = _updateButton.hidden = NO;
                
                _table.alpha = _updateButton.alpha = 0;
                [UIView animateWithDuration:.35 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:8 options:0 animations:^{
                    _table.alpha = _updateButton.alpha = 1;
                } completion:^(BOOL finished) {
                    _table.alpha = _updateButton.alpha = 1;
                }];
                break;
            }
            case HttpCode_UnAuthorizeRequest:
                // Renew credentials, and get profile info again
                [[[UIAlertView alloc] initWithTitle:@"You need to re-login, as login as expired. Development only" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                [self.navigationController popToRootViewControllerAnimated:YES];

                break;
            default:
                // Some error occured, simply alert some error occured and go back
                [[[UIAlertView alloc] initWithTitle:@"Some error occured." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                break;
        }
    }else if (downloader == _updateProfileConnection){
        self.disableEditing = NO;
        
        switch (parser.httpCode) {
            case HttpCode_Success:
            {
                [[[UIAlertView alloc] initWithTitle:@"Update complete" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
                
            case HttpCode_UnAuthorizeRequest:
            {
                [[[UIAlertView alloc] initWithTitle:@"Update failed due to authorization failure. Only for development" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
                break;
                
            case HttpCode_UpdateProfileInvalidRequest:
            {
                [[[UIAlertView alloc] initWithTitle:@"Some error occured updating" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
            default:
                break;
        }
    }
    
        
}

-(void)downloader:(Downloader*)downloader beginToDownloadLink:(NSURL*)link{
    _loadingActivityContainer.hidden = NO;
    _loadingActivityContainer.alpha = 1;
    [_activity startAnimating];

}
@end
