//
//  ApiResponseParser.m
//  KrushDemo
//
//  Created by Atif Khan on 9/7/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "ApiResponseParser.h"
#import "UserData.h"


@implementation ApiResponseParser
/*
 HttpCode_Unkown                     = 0,
 HttpCode_SignUpUserCreated          = 201,
 HttpCode_SignUpEmailExist           = 400,
 HttpCode_SignInSuccess              = 200,
 HttpCode_SignInEmailRequired        = 400,
 HttpCode_SignInInvalid              = 422,
 HttpCode_UpdateProfileSuccess       = 204,
 HttpCode_UpdateProfileFieldMissing  = 400,
 HttpCode_LogoutSuccess              = 302,
 HttpCode_LogoutInvalidToken         = 422
 */

-(id )valueForKey:(NSString *)key inDictionary:(NSDictionary *)dictionary{
    id value = dictionary[key];
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}

-(void) parseData:(NSData *)data networkStatusCode:(int )networkStatusCode{
    
    NSString *const serverResponseParams_accessToken        = @"access_token";
    NSString *const serverResponseParams_refreshToken       = @"refresh_token";
    NSString *const serverResponseParams_tokenType          = @"token_type";
    NSString *const serverResponseParams_userName           = @"userName";
    
    NSString *const serverResponseParams__profile_fname             = @"firstName";
    NSString *const serverResponseParams__profile_lname             = @"lastName";
    NSString *const serverResponseParams__profile_gender            = @"gender";
    NSString *const serverResponseParams__profile_country           = @"country";
    NSString *const serverResponseParams__profile_dob               = @"dateOfBirth";
    NSString *const serverResponseParams__profile_phone             = @"phoneNumber";

    
    switch (networkStatusCode) {
        case 201:
        case 200:
        case 400:
        case 422:
        case 204:
        case 302:
        case 401:
            self.httpCode = networkStatusCode;
            break;
            
        default:
            self.httpCode = HttpCode_Unkown;
            break;
    }
    
    NSDictionary *json = data?[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]:nil;
    if(!json){
        NSLog(@"Data :%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    self.accessToken = [self valueForKey:serverResponseParams_accessToken inDictionary:json];
    self.refreshToken = [self valueForKey:serverResponseParams_refreshToken inDictionary:json];
    self.tokenType = [self valueForKey:serverResponseParams_tokenType inDictionary:json];
    self.userName   = [self valueForKey:serverResponseParams_userName inDictionary:json];
    self.message = [self valueForKey:@"Message" inDictionary:json];
    
    UserData *uData     = [[UserData alloc] init];
    uData.firstName     = [self valueForKey:serverResponseParams__profile_fname     inDictionary:json];
    uData.lastName      = [self valueForKey:serverResponseParams__profile_lname     inDictionary:json];
    uData.gender        = [self valueForKey:serverResponseParams__profile_gender    inDictionary:json];
    uData.country       = [self valueForKey:serverResponseParams__profile_country   inDictionary:json];
    uData.dobString     = [self valueForKey:serverResponseParams__profile_dob       inDictionary:json];
    uData.phoneNumber   = [self valueForKey:serverResponseParams__profile_phone     inDictionary:json];

    self.profileUserData = uData;
    
}

@end
