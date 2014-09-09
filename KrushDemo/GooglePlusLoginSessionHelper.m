//
//  GooglePlusLoginSessionHelper.m
//  KrushDemo
//
//  Created by Atif Khan on 9/7/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "GooglePlusLoginSessionHelper.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

NSString *const kGooglePlusNotificationSignedIn                                 = @"com.norq.googleplussignin_success";
NSString *const kGooglePlusNotificationSignInErrorOccured                       = @"com.norq.googleplussignin_erroroccured";
NSString *const kGooglePlusNotificationUserReturnedBackWithOutAttemptToSignIn   = @"com.norq.googleplussignin_userReturnedBackWithOutAttemptToSignIn";


@implementation GooglePlusLoginSessionHelper{
    BOOL waitingForGooglePlusAuthentication;
}

-(id)init{
    self = [super init];
    if (self) {
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.shouldFetchGooglePlusUser = YES;
        signIn.clientID = kGooglePlusClientId;
        signIn.scopes = @[ kGTLAuthScopePlusUserinfoProfile ];
        signIn.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

+(GooglePlusLoginSessionHelper *)sharedInstance{
    static GooglePlusLoginSessionHelper *instance = nil;
    
    if (!instance) {
        instance = [GooglePlusLoginSessionHelper new];
    }
    return instance;
}

-(void)attemptToSignInUser{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    waitingForGooglePlusAuthentication = YES;
    [signIn authenticate];
}

// The authorization has finished and is successful if |error| is |nil|.
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error{
#ifdef DEBUG
    NSLog(@"%s,\n Received error %@ and auth object %@",__func__, error, auth);
#endif
    waitingForGooglePlusAuthentication = NO;
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGooglePlusNotificationSignInErrorOccured object:error];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGooglePlusNotificationSignedIn object:nil];
    }
    [[GPPSignIn sharedInstance] disconnect];
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
   // [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)didDisconnectWithError:(NSError *)error{
    waitingForGooglePlusAuthentication = NO;
#ifdef DEBUG
    NSLog(@"%s,\n Received error %@ ",__func__, error);
#endif
}
//*****************************************************
#pragma mark - Notification call backs
//*****************************************************

-(void )applicationDidBecomeActive:(NSNotification *)notification{
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
    if (waitingForGooglePlusAuthentication ) {
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        [signIn disconnect];
       // [[NSNotificationCenter defaultCenter] postNotificationName:kGooglePlusNotificationUserReturnedBackWithOutAttemptToSignIn object:nil];
    }
}

@end
