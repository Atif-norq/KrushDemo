//
//  UserData.h
//  KrushDemo
//
//  Created by Atif Khan on 9/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    UserSignInMethod_Email,
    UserSignInMethod_Facebook
}UserSignInMethod;

@interface UserData : NSObject<NSCoding, NSSecureCoding, NSCopying>

@property (nonatomic, strong) NSString *accessCode;
@property (nonatomic, strong) NSString *refreshCode;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *dobString;

@property (nonatomic, strong) NSString *emailID;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *externalServiceAccessToken;

@property (nonatomic, assign) UserSignInMethod signInMethod;

@property (nonatomic, strong) NSMutableDictionary *facebookUserInfoData;

@property (nonatomic, strong) NSDictionary *facebookUserInfo;

-(BOOL )save;
-(BOOL )deleteData;

-(NSString *)externaUserEmail;
-(NSString *)externaUserFirstName;
-(NSString *)externaUserLastName;
-(NSString *)externalUserProfileName;
-(NSString *)externalUserBirthDay;

-(NSString *)providerName;

+(UserData *)currentUserSavedData;

+(UserData *)currentSignedInFacebookUser:(NSDictionary *)fbUserInfo accessToken:(NSString *)accessToken;


@end
