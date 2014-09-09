//
//  UserData.m
//  KrushDemo
//
//  Created by Atif Khan on 9/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "UserData.h"

NSString *const externalSigningServiceFacebook         = @"Facebook";


static NSString *kCodingKey_FName           = @"firstname";
static NSString *kCodingKey_LName           = @"lastname";
static NSString *kCodingKey_Email           = @"emailid";
static NSString *kCodingKey_Password        = @"password";
static NSString *kCodingKey_SignInMethod    = @"signinmethodtype";

@implementation UserData

+(NSURL *)currentUserDataSavePath{
    NSURL *documentDirecrory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *savePathURL = [documentDirecrory URLByAppendingPathComponent:@"currentUserInfo.data"];
    return savePathURL;
}

- (id)copyWithZone:(NSZone *)zone{
    UserData *uData                     = [[UserData alloc] init];
    uData.accessCode                    = self.accessCode;
    uData.refreshCode                   = self.refreshCode;
    uData.firstName                     = self.firstName;
    uData.lastName                      = self.lastName;
    uData.phoneNumber                   = self.phoneNumber;
    uData.country                       = self.country;
    uData.gender                        = self.gender;
    uData.dobString                     = self.dobString;
    uData.emailID                       = self.emailID;
    uData.externalServiceAccessToken    = self.externalServiceAccessToken;
    uData.signInMethod                  = self.signInMethod;
    uData.facebookUserInfoData          = [self.facebookUserInfoData mutableCopy];
    uData.facebookUserInfo              = [self.facebookUserInfoData mutableCopy];
    
    return uData;
}

-(NSString *)getStringFromDictionary:(NSDictionary *)dictionary forKey:(NSString *)key{
    NSString *text = dictionary[key];
    if ([text isKindOfClass:[NSString class]]) {
        return text;
    }
    return text;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.firstName forKey:kCodingKey_FName];
    [aCoder encodeObject:self.lastName forKey:kCodingKey_LName];
    [aCoder encodeObject:self.emailID forKey:kCodingKey_Email];
    [aCoder encodeObject:self.password forKey:kCodingKey_Password];
    [aCoder encodeInt:self.signInMethod forKey:kCodingKey_SignInMethod];
}

- (instancetype )initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.firstName  = [aDecoder decodeObjectForKey:kCodingKey_FName];
        self.lastName   = [aDecoder decodeObjectForKey:kCodingKey_LName];
        self.emailID    = [aDecoder decodeObjectForKey:kCodingKey_Email];
        self.password   = [aDecoder decodeObjectForKey:kCodingKey_Password];
        
        self.signInMethod   = [aDecoder decodeIntForKey:kCodingKey_SignInMethod];
    }
    return self;
}

+(BOOL)supportsSecureCoding{
    return YES;
}


-(BOOL )save{
    NSURL *url = [UserData currentUserDataSavePath];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToURL:url atomically:YES];
}

-(BOOL )deleteData{
    NSURL *url = [UserData currentUserDataSavePath];
    return [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
}

-(NSString *)externaUserEmail{
    if (self.signInMethod == UserSignInMethod_Facebook) {
        return [self getStringFromDictionary:_facebookUserInfo forKey:@"email"];
    }
    return self.emailID;
}

-(NSString *)externaUserFirstName{
    if (self.signInMethod == UserSignInMethod_Facebook) {
        return [self getStringFromDictionary:_facebookUserInfo forKey:@"first_name"];
    }
    return self.firstName;
}
-(NSString *)externaUserLastName{
    if (self.signInMethod == UserSignInMethod_Facebook) {
        return [self getStringFromDictionary:_facebookUserInfo forKey:@"last_name"];
    }
    return self.lastName;
}
-(NSString *)externalUserProfileName{
    
    if (self.signInMethod == UserSignInMethod_Facebook) {
        return [self externaUserEmail];
        //return [self getStringFromDictionary:_facebookUserInfo forKey:@"name"];
    }
    return self.firstName;
}

-(NSString *)externalUserBirthDay{
    if (self.signInMethod == UserSignInMethod_Facebook) {
        return [self getStringFromDictionary:_facebookUserInfo forKey:@"birthday"];
    }
    return nil;
}


-(NSString *)providerName{
    if (self.signInMethod == UserSignInMethod_Email) {
        return nil;
    }else{
        return externalSigningServiceFacebook;
    }
}

+(UserData *)currentUserSavedData{
    NSURL *url = [UserData currentUserDataSavePath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

+(UserData *)currentSignedInFacebookUser:(NSDictionary *)fbUserInfo accessToken:(NSString *)accessToken{
    
    UserData *userData = [UserData new];
    userData.signInMethod = UserSignInMethod_Facebook;
    userData.facebookUserInfo = fbUserInfo;
    userData.externalServiceAccessToken = accessToken;
    
    userData.emailID    = userData.externaUserEmail;
    userData.firstName  = userData.externaUserFirstName;
    userData.lastName   = userData.externaUserLastName;
    userData.dobString  = userData.externalUserBirthDay;
    
    return userData;
}


@end
