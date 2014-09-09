//
//  UserSessionManager.h
//  KrushDemo
//
//  Created by Atif Khan on 9/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"

/////// -- Constants

extern NSString *const refreshTokenUpdatedNotification;
extern NSString *const refreshTokenUpdateFailedNotification;
extern NSString *const UserSigOutFromApplicationNotification;

extern NSString *const autherizationHeaderKey;


typedef enum {
    /// When some unkown error occured
    SessionErrorCode_SomeErrorOccured = 0,
    SessionErrorCode_NoError,
    SessionErrorCode_EmailExist,
    SessionErrorCode_NetworkError,
    /// When sign in failed due to either wrong username or password.
    SessionErrorCode_WrongEmailPassword,
    SessionErrorCode_InternalServerError,
    SessionErrorCode_MissingFields
}SessionErrorCode;

typedef enum {
    UserSignInStatus_NotSignedIn = 0,
    /// It represents a state while attempting to sign-in
    UserSignInStatus_SigningIn,
    /// When user is signed as registered user or a guest user.
    UserSignInStatus_SignedIn,
    UserSignInStatus_RefereshingSignInToken
}UserSignInStatus;


/////// -- Protocols Declartion

@class UserSessionManager;

@protocol UserSignInDelegate <NSObject>

/// Common Call backs

/// SignIn Call backs

/**
 *   @brief  Called when sign in process completes irrespective of if sign-in succed or failed.
 *
 *   @param  sessionManager This is session manager instance calling this callback
 *   @param  error This is the network error if occured, else nil
 *   @param  errorCode This is the native errorcode if occured, else SessionErrorCode_NoError
 *
 */
-(void )sessionManager:(UserSessionManager *)sessionManager signInCompleteWithNetworkError:(NSError *)error nativeErrorCode:(SessionErrorCode )errorCode forUser:(UserData *)user;


@end

@protocol UserSignUpDelegate <NSObject>

/// Common Call backs

-(void )sessionManager:(UserSessionManager *)sessionManager signUpCompleteWithNetworkError:(NSError *)error nativeErrorCode:(SessionErrorCode )errorCode forUserData:(UserData *)user;


@end


/////// -- Class Declartion

@interface UserSessionManager : NSObject

@property (nonatomic, strong) NSString *tokenType;

@property (nonatomic, strong) NSString *signedInUserID;

@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong) NSString *refreshToken;

/// Use this property to set delegate for session related call backs;
@property (nonatomic, weak) id<UserSignInDelegate> signindelegate;
@property (nonatomic, weak) id<UserSignUpDelegate> signupdelegate;


/// Use this property to check user login status
@property (nonatomic, readonly) UserSignInStatus userSignInStatus;

/// Use this property to check if user is signed in as guest. Default is YES. Even if user is not signed in. Use userSignInStatus property to get login status
@property (nonatomic, readonly) BOOL guestUser;

+(instancetype )sharedInstance;

/**
 *   @brief  This method is used to register a user with required user info for sign in.
 *   @param  "signInData" It contains user sign-in data like username/password.
 */
-(void )signUpWithSignInData:(UserData *)signInData;

/**
 *   @brief  Sign-in User
 *
 *   @param  signInData : Sign in credentials
 *
 */
-(void )signInWithSignInData:(UserData *)signInData;


/**
 *   @brief  This method sign out current login session
 */
-(void )signOutCurrentUser;

/**
 *   @brief  Cancel sign in process
 *
 */
-(void )cancelSignUpProcess;


- (void )renewSession;

-(NSMutableURLRequest *)authorizedPostRequest:(NSDictionary *)dictionary url:(NSURL *)url;

-(NSMutableURLRequest *)authorizeUpdateRequestForUser:(UserData *)userData;

-(NSString *)autherizationHeader;

-(NSMutableURLRequest *)requestForGetProfile;

-(NSMutableURLRequest *)resetPasswordRequestForEmail:(NSString *)emailID;

-(NSMutableURLRequest *)authorizedLogoutRequest;

@end
