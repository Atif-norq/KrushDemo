//
//  ForgotPasswordViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 8/31/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "NSString+AttributedFormatedString.h"
#import "NSString+Addition.h"
#import "LoadActivityViewController.h"
#import "TransitionDelegate.h"
#import "Downloader.h"
#import "UserSessionManager.h"

@interface ForgotPasswordViewController ()<UITextFieldDelegate, DownloaderResponseDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailIdTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) LoadActivityViewController *activty;
@property (nonatomic, strong) TransitionDelegate *delegate;
@property (nonatomic, strong) Downloader *forgetPasswordConnection;

@end

@implementation ForgotPasswordViewController

//*****************************************************
#pragma mark - VC call backs
//*****************************************************

-(void)requestPassword{
    [_emailIdTextField resignFirstResponder];
    [_forgetPasswordConnection cancel];
    self.forgetPasswordConnection = [[Downloader alloc] initWithRequest:[[UserSessionManager sharedInstance] resetPasswordRequestForEmail:_emailIdTextField.text] cachePolicy:NSURLRequestReloadIgnoringCacheData delegate:self autoStartEnabled:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isMovingToParentViewController) {
        [_emailIdTextField becomeFirstResponder];
    }else {
        [_emailIdTextField resignFirstResponder];
    }
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   /*
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    */
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.delegate = [TransitionDelegate new];
    [_sendButton setBackgroundColor:[UIColor lightGrayColor]];
    _sendButton.enabled = NO;
    _sendButton.titleLabel.font = [FontHelper fontProximaBoldSize:22];
    
    _emailIdTextField.attributedPlaceholder = [@"Email (or Username)" attrMStringWithFont:[UIFont systemFontOfSize:16] alignment:NSTextAlignmentLeft color:[UIColor lightTextColor]];
}

//*****************************************************
#pragma mark - Textfield call backs
//*****************************************************

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = textField.text?textField.text:@"";
    newString = [newString stringByReplacingCharactersInRange:range withString:string];
    if ([newString isAValidEmailID]) {
        _sendButton.enabled = YES;
        [_sendButton setBackgroundColor:[UIColor colorWithRed:225/255.f green:79/255.f blue:10/255.f alpha:1.]];
    }  else{
        _sendButton.enabled = NO;
        [_sendButton setBackgroundColor:[UIColor lightGrayColor]];
    }
    return YES;
}

//*****************************************************
#pragma mark - Keyboard targets
//*****************************************************

-(void )keyboardWillShow:(NSNotification *)notification
{
    //nextButtonBottomConstraint
    
}

-(void )keyboardWillHide:(NSNotification *)notification
{
//    CGRect keyboardRect = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottomMargin =  0;
    float duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.95 initialSpringVelocity:9 options:0 animations:^{
        _sendButtonBottomConstraint.constant = 0;
        [self.view layoutSubviews];
    } completion:^(BOOL finished) {
        [self.view layoutIfNeeded];
    }];
    
    NSLog(@"%s\n\nMargin:%f",__func__, bottomMargin);
}

-(void )keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottomMargin = self.view.bounds.size.height - keyboardRect.origin.y + _sendButtonBottomConstraint.constant - 2;
    float duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.95 initialSpringVelocity:9 options:0 animations:^{
        _sendButtonBottomConstraint.constant = bottomMargin;
        [self.view layoutSubviews];
    } completion:^(BOOL finished) {
        [self.view layoutIfNeeded];
    }];
    
    NSLog(@"%s\n\nMargin:%f",__func__, bottomMargin);
}


- (IBAction)sendForgetPassword:(id)sender
{
    if ([_emailIdTextField.text isAValidEmailID]) {
        self.activty = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadActivityViewController"];
        _activty.loadingMessage = @"Requesting password...";
        _activty.modalPresentationStyle = UIModalPresentationCustom;
        _activty.transitioningDelegate = _delegate;
        [self presentViewController:_activty animated:YES completion:^{
            [self requestPassword];
        }];
    }
}

//*****************************************************
#pragma mark - Alert view
//*****************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self requestPassword];
    }else{
        [_activty dismissViewControllerAnimated:YES completion:^{
            self.activty = nil;
        }];
    }
}

//*****************************************************
#pragma mark - Downloader
//*****************************************************

-(void)downloader:(Downloader*)downloader errorDownloading:(NSError*)error{
    [[[UIAlertView alloc] initWithTitle:@"Unable to connect to server" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Re try", nil] show];
}

-(void)downloader:(Downloader*)downloader dataDownloadedDownloadedForLink:(NSURL*)link{
    
#ifdef DEBUG
    NSLog(@"%s, %@",__func__, [[NSString alloc] initWithData:downloader.mData encoding:NSUTF8StringEncoding]);
#endif

    ApiResponseParser *parser = [[ApiResponseParser alloc] init];
    [parser parseData:downloader.mData networkStatusCode:downloader.networkStatusCode];
    
    switch (parser.httpCode) {
        case HttpCode_Success:
        {
            [_activty dismissViewControllerAnimated:YES completion:^{
                self.activty = nil;
            }];
            
            [[[UIAlertView alloc] initWithTitle:@"Please check your email inbox for reset password email." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            
            break;
        }
        case HttpCode_ForgotPasswordEmailNotFound:
            
        {
            [_activty dismissViewControllerAnimated:YES completion:^{
                self.activty = nil;
            }];
            [[[UIAlertView alloc] initWithTitle:@"Email id is not registered with us." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];

        }
            break;
        default:
        {
            [_activty dismissViewControllerAnimated:YES completion:^{
                self.activty = nil;
            }];
            [[[UIAlertView alloc] initWithTitle:@"Some error occured" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
            break;
    }
}

-(void)downloader:(Downloader*)downloader beginToDownloadLink:(NSURL*)link{

}
-(void)downloader:(Downloader*)downloader dataDownloadProgress:(float)progress forLink:(NSURL*)link{

}
@end
