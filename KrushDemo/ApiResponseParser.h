//
//  ApiResponseParser.h
//  KrushDemo
//
//  Created by Atif Khan on 9/7/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserData;

typedef enum {
    HttpCode_Unkown                     = 0,
    HttpCode_Success                    = 200,
    HttpCode_SignUpUserCreated          = 201,
    HttpCode_SignUpEmailExist           = 400,
    HttpCode_SignInSuccess              = 200,
    HttpCode_SignInMissingFields        = 400,
    HttpCode_SignInInvalid              = 422,
    HttpCode_UpdateProfileSuccess       = 204,
    HttpCode_UpdateProfileFieldMissing  = 400,
    HttpCode_LogoutSuccess              = 302,
    HttpCode_LogoutInvalidToken         = 422,
    HttpCode_UnAuthorizeRequest             = 401,
    HttpCode_UpdateProfileInvalidRequest    = 400,
    HttpCode_ForgotPasswordEmailNotFound    = 400
    
}HttpCode;

@interface ApiResponseParser : NSObject
@property (nonatomic, assign) HttpCode httpCode;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) UserData *profileUserData;

-(void) parseData:(NSData *)data networkStatusCode:(int )networkStatusCode;
@end
