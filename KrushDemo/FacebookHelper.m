//
//  FacebookHelper.m
//  KrushDemo
//
//  Created by Atif Khan on 9/3/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "FacebookHelper.h"
#import "UserSessionManager.h"

NSString *facebookSessionNotifiction_LoginCompleted         = @"com.norq.shopex.fblogincomplelted";
NSString *facebookSessionNotifiction_LoginCanceledByUser    = @"com.norq.shopex.fblogincanceled";
NSString *facebookSessionNotifiction_SessionInvalid         = @"com.norq.shopex.fbinvalidsession";
NSString *facebookSessionNotifiction_LoginFailed            = @"com.norq.shopex.fbloginfailedforunkownreason";
NSString *facebookSessionNotifiction_UserLogedOut           = @"com.norq.shopex.fbclosesession";

@implementation FacebookHelper

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        self.fbUserInfoDictionary = nil;
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        
        [[NSNotificationCenter defaultCenter] postNotificationName:facebookSessionNotifiction_LoginCompleted object:session];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        self.fbUserInfoDictionary = nil;
        NSLog(@"Session closed");
        [[NSNotificationCenter defaultCenter] postNotificationName:facebookSessionNotifiction_UserLogedOut object:session];

        // Show the user the logged-out UI
        
        //[self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
         
            [[NSNotificationCenter defaultCenter] postNotificationName:facebookSessionNotifiction_LoginFailed object:error];

            //[self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:facebookSessionNotifiction_LoginCanceledByUser object:error];

                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                
                [[NSNotificationCenter defaultCenter] postNotificationName:facebookSessionNotifiction_SessionInvalid object:error];
                //[self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:facebookSessionNotifiction_LoginFailed object:error userInfo:errorInformation];

               
                //[self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        self.fbUserInfoDictionary = nil;
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
       
        // [self userLoggedOut];
    }
}


+(instancetype )sharedInstance{
    static FacebookHelper *helper = nil;
    if (!helper) {
        helper = [FacebookHelper new];
    }
    return helper;
}

-(void ) attemptForFacebookLoginWithPromptFromUser:(BOOL) allowUserPrompt{
    
    if (allowUserPrompt) {
        NSArray *permissions = @[@"public_profile",@"user_birthday",@"read_stream",@"email"];
        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        // Set the active session
        [FBSession setActiveSession:session];
        // Open the session
        [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                completionHandler:^(FBSession *session,
                                    FBSessionState status,
                                    NSError *error) {
                    // Respond to session state changes,
                    // ex: updating the view
                    if (error) {
                        NSDictionary *userInfo = [error userInfo];
                        NSString *innerError = [userInfo valueForKey:FBErrorLoginFailedReason];
                        if([innerError isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue]){
                            [FBSession openActiveSessionWithReadPermissions:permissions
                                                               allowLoginUI:allowUserPrompt
                                                          completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                                              // Handler for session state changes
                                                              // This method will be called EACH time the session state changes,
                                                              // also for intermediate states and NOT just when the session open
                                                              [self sessionStateChanged:session state:state error:error];
                                                          }];
                        }else {
                            [self sessionStateChanged:session state:status error:error];
                        }
                    }else{
                        [self sessionStateChanged:session state:status error:error];
                    }

                }];
        /*
        // If there's one, just open the session silently, without showing the user the login UI
       
    
        */
    }
}

-(BOOL) isUserLoggedIn{
    return [[FBSession activeSession] isOpen];
}

-(void ) closeLoginSession{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [self sessionStateChanged:session state:state error:error];
     }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

+(NSString *)facebookAccessToken{
    NSString *accessToken = [[FBSession activeSession] accessTokenData].accessToken;
    return accessToken;
}

@end
