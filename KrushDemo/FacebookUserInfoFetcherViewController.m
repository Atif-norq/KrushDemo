//
//  FacebookUserInfoFetcherViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 9/3/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "FacebookUserInfoFetcherViewController.h"
#import "UserSessionManager.h"


@interface FacebookUserInfoFetcherViewController ()<UserSignInDelegate, UIAlertViewDelegate>
{
    UserData *uData;
}
@end


@implementation FacebookUserInfoFetcherViewController


-(void )addCallbacksForFacebookSessionNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbloginCompleted:) name:facebookSessionNotifiction_LoginCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbloginLoginCancelled:) name:facebookSessionNotifiction_LoginCanceledByUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbloginSessionInvalid:) name:facebookSessionNotifiction_SessionInvalid object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbloginFailed:) name:facebookSessionNotifiction_LoginFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbloginUserLogOut:) name:facebookSessionNotifiction_UserLogedOut object:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    if ([[FacebookHelper sharedInstance] isUserLoggedIn]) {
        self.loadingMessage = @"Getting general information...";
    }else{
        self.loadingMessage = @"Logging to facebook...";
    }
    
    [self addCallbacksForFacebookSessionNotifications];
}

-(void)dealloc{
    if ([UserSessionManager sharedInstance].signindelegate == self) {
        [UserSessionManager sharedInstance].signindelegate = nil;
    }
}

-(void )signInNatively{
    
    [UserSessionManager sharedInstance].signindelegate = self;
    self.loadingMessage = @"Signing-in to Shopex...";
    [[UserSessionManager sharedInstance] signInWithSignInData:uData];
}

-(void) getFacebookUserInformation{
    self.loadingMessage = @"Getting general information...";
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            
            [_delegate facebookUserInformationVC:self userInfo:result];
            
            if ([_delegate facebookUserInformationVCShouldAttemptToLoginNatively:self]) {
                uData = [UserData currentSignedInFacebookUser:result accessToken:[FacebookHelper facebookAccessToken]];
                [self signInNatively];
            }
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            
            NSLog(@"Error :%@", error.description);
            [_delegate facebookUserInformationVC:self failedToGetUserInfoWithError:error];

        }
    }];
}

-(void )loginUser{
    self.loadingMessage = @"Logging to facebook...";
    [[UserSessionManager sharedInstance] signOutCurrentUser];

    [[FacebookHelper sharedInstance] attemptForFacebookLoginWithPromptFromUser:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.isBeingPresented || self.isMovingToParentViewController) {
        if (_userData) {
            uData = _userData;
            [self signInNatively];
        }else{
            if ([[FacebookHelper sharedInstance] isUserLoggedIn]) {
                [self getFacebookUserInformation];
            }else{
                [self loginUser];
            }
        }
        
    }
}

//*****************************************************
#pragma mark - Notification callbacks
//*****************************************************

-(void )fbloginCompleted:(NSNotification *)notification{
    [self getFacebookUserInformation];
}

-(void )fbloginLoginCancelled:(NSNotification *)notification{
    [_delegate facebookUserInformationVCLoginCanceledByUser:self];
}

-(void )fbloginSessionInvalid:(NSNotification *)notification{
    [self loginUser];
}

-(void )fbloginFailed:(NSNotification *)notification{
    [_delegate facebookUserInformationVC:self failedToLoginToFB:notification.object];
    //[_delegate facebookUserInformationVC:self failedToGetUserInfoWithError:notification.object];
}

-(void )fbloginUserLogOut:(NSNotification *)notification{
    [_delegate facebookUserInformationVC:self failedToLoginToFB:notification.object];
    //[_delegate facebookUserInformationVC:self failedToGetUserInfoWithError:notification.object];

}

//*****************************************************
#pragma mark - Alert View delegate
//*****************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [_delegate facebookUserInformationVCUserSignedNatively:self failedWithError:nil];
    }else {
        [self signInNatively];
    }
}

//*****************************************************
#pragma mark - Sign In delegate
//*****************************************************

-(void )sessionManager:(UserSessionManager *)sessionManager signInCompleteWithNetworkError:(NSError *)error nativeErrorCode:(SessionErrorCode )errorCode forUser:(UserData *)user{
    
    if (errorCode != SessionErrorCode_NoError ) {
        error = [NSError errorWithDomain:@"Unable to sign in at this moment. Please try later" code:0 userInfo:nil];
    }
    
    if (errorCode == SessionErrorCode_NetworkError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign-in failed" message:@"Unable to connect to server. Please check your internet connection." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Re-try", nil];
        [alert show];

    }else if(errorCode == SessionErrorCode_NoError ){
     
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign-in complete" message:@"Successfully signed in" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         [alert show];
        
        [_delegate facebookUserInformationVCUserSignedNatively:self];

    }else if(errorCode == SessionErrorCode_MissingFields ){
        [_delegate facebookUserInformationVCUserSignedNativelyMissingField:self userData:user];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Sign-in failed" message:@"Unable to sign in at this moment. Please try later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        
        [_delegate facebookUserInformationVCUserSignedNatively:self failedWithError:error];
    }
}


@end
