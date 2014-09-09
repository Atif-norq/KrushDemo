//
//  FacebookHelper.h
//  KrushDemo
//
//  Created by Atif Khan on 9/3/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *facebookSessionNotifiction_LoginCompleted;
extern NSString *facebookSessionNotifiction_LoginCanceledByUser;
extern NSString *facebookSessionNotifiction_SessionInvalid;
extern NSString *facebookSessionNotifiction_LoginFailed;
extern NSString *facebookSessionNotifiction_UserLogedOut;

@interface FacebookHelper : NSObject

+(instancetype )sharedInstance;

@property (nonatomic, strong ) NSDictionary *fbUserInfoDictionary;

-(void ) attemptForFacebookLoginWithPromptFromUser:(BOOL) allowUserPrompt;

-(BOOL) isUserLoggedIn;

-(void ) closeLoginSession;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

+(NSString *)facebookAccessToken;

@end
