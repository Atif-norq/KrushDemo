//
//  UserSessionManager.m
//  KrushDemo
//
//  Created by Atif Khan on 9/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "UserSessionManager.h"
#import "NSMutableURLRequest+RequestHeaderTypeAddition.h"
#import "Downloader.h"
#import "GooglePlusLoginSessionHelper.h"

NSString *const refreshTokenUpdatedNotification         = @"com.norq.tokenUpdatedNotification" ;
NSString *const refreshTokenUpdateFailedNotification    = @"com.norq.tokenUpdateFailedNotification";
NSString *const UserSigOutFromApplicationNotification   = @"com.norq.tokenSignOutNotification";

NSString *const autherizationHeaderKey                  = @"Authorization";

NSString *const serverParams_userName                   = @"userName";
NSString *const serverParams_password                   = @"Password";
NSString *const serverParams_confirmPassword            = @"confirmPassword";
NSString *const serverParams_phoneNumber                = @"phoneNumber";
NSString *const serverParams_country                    = @"Country";
NSString *const serverParams_birthDate                  = @"DateOfBirth";
NSString *const serverParams_gender                     = @"Gender";
NSString *const serverParams_grantType                  = @"grant_type";
NSString *const serverParams_refreshToken               = @"refresh_token";
NSString *const serverParams_clientID                   = @"client_id";
NSString *const serverParams_externalAccessToken        = @"ExternalAccessToken";
NSString *const serverParams_email                      = @"Email";
NSString *const serverParams_firstName                  = @"firstname";
NSString *const serverParams_lastName                  = @"lastname";
NSString *const serverParams_provider                  = @"provider";



NSString *const serverResponseParams_accessToken        = @"access_token";
NSString *const serverResponseParams_refreshToken       = @"refresh_token";
NSString *const serverResponseParams_tokenType          = @"token_type";


static NSString *clientID = @"ngAuthApp";

static NSString *grantTypeLogin         = @"password";
static NSString *grantTypeRefreshLogin  = @"refresh_token";

static NSString *defaultSignInTokenKey          = @"user.login.token";
static NSString *defaultSignInRefreshTokenKey   = @"user.login.refresh.token";
static NSString *defaultSignInTokenTypeKey      = @"user.login.token.tokentype";


@interface UserSessionManager()<DownloaderResponseDelegate>

@end

@implementation UserSessionManager{
    Downloader *signupconnection;
    Downloader *signinconnection;
    Downloader *refreshsignedintokenconnection;

    UserData *signingUserData;
    
    UserSignInStatus signInStatus;
}


//*****************************************************
#pragma mark - Private
//*****************************************************

-(UserSignInStatus)userSignInStatus{
    return signInStatus;
}

-(void )saveUserSignInInformation{
    
    [[NSUserDefaults standardUserDefaults] setValue:self.token
                                             forKey:defaultSignInTokenKey];
    
    [[NSUserDefaults standardUserDefaults] setValue:self.refreshToken
                                             forKey:defaultSignInRefreshTokenKey];
    
    [[NSUserDefaults standardUserDefaults]  setValue:self.tokenType forKey:defaultSignInTokenTypeKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}



//*****************************************************
#pragma mark - Public
//*****************************************************

+(instancetype )sharedInstance{
    static UserSessionManager *shared = nil;
    if (!shared) {
        shared = [[UserSessionManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:shared selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return shared;
}


-(void )signUpWithSignInData:(UserData *)signInData{
    //__weak typeof(self) weakSelf = self;
    
    
    /// Prepare sign - up request.
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/api/account/register"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:signInData.emailID forKey:serverParams_userName];
    [dictionary setValue:signInData.emailID forKey:serverParams_email];
    [dictionary setValue:signInData.password forKey:serverParams_password];
    [dictionary setValue:signInData.firstName forKey:serverParams_firstName];
    [dictionary setValue:signInData.lastName forKey:serverParams_lastName];
    [dictionary setValue:signInData.phoneNumber forKey:serverParams_phoneNumber];
    [dictionary setValue:@"United Arab Emirates" forKey:serverParams_country];
    [dictionary setValue:signInData.gender forKey:serverParams_gender];
    [dictionary setValue:signInData.dobString    forKey:serverParams_birthDate];
    
#ifdef DEBUG
    NSLog(@"%s, %@",__func__,[dictionary description]);
#endif
    [request setUpURLEncodeRequestTypeParamters:dictionary];
    
    NSURLSessionDataTask *dataTask = [[UtilityHelper defaultDownloadSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error) {
                [_signupdelegate sessionManager:self signUpCompleteWithNetworkError:error nativeErrorCode:SessionErrorCode_NetworkError forUserData:signInData];
            }else {
                ApiResponseParser *parser = [ApiResponseParser new];
                NSHTTPURLResponse *httpCode = (NSHTTPURLResponse *)response;
                
                //[parser parseData:downloader.mData networkStatusCode:downloader.networkStatusCode];
                [parser parseData:data networkStatusCode:httpCode.statusCode];
                switch (parser.httpCode) {
                    case HttpCode_SignUpUserCreated:
                        [_signupdelegate sessionManager:self signUpCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_NoError forUserData:signInData];
                        
                        break;
                        
                    case HttpCode_SignUpEmailExist:
                        [_signupdelegate sessionManager:self signUpCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_EmailExist forUserData:signInData];
                        
                        break;
                    default:
                        [_signupdelegate sessionManager:self signUpCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_SomeErrorOccured forUserData:signInData];
                        break;
                }
            }
        }];
        
    }];
    [dataTask resume];
    /// Start connection for request.
    //signupconnection = [[Downloader alloc] initWithRequest:request cachePolicy:NSURLRequestReloadIgnoringCacheData delegate:self autoStartEnabled:YES];
}

-(void )signInWithSignInData:(UserData *)signInData{
    
    //    __weak typeof(self) weakSelf = self;
    [signinconnection cancel];
    
    // Set sign-in status to signing in
    signInStatus = UserSignInStatus_SigningIn;
    signingUserData = signInData;
    
    /// Prepare sign - up request.
    NSMutableURLRequest *request = nil;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (signInData.signInMethod == UserSignInMethod_Email) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/token"]];
        [dictionary setValue:signInData.emailID forKey:serverParams_userName];
        [dictionary setValue:signInData.password forKey:serverParams_password];
        [dictionary setValue:grantTypeLogin forKey:serverParams_grantType];
        [dictionary setValue:clientID forKey:serverParams_clientID];
    }else {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/api/account/RegisterExternal"]];
        [dictionary setValue:signInData.emailID forKey:serverParams_userName];
        [dictionary setValue:signInData.emailID forKey:serverParams_email];
        [dictionary setValue:signInData.firstName forKey:serverParams_firstName];
        [dictionary setValue:signInData.lastName forKey:serverParams_lastName];
        [dictionary setValue:signInData.dobString forKey:serverParams_birthDate];
        [dictionary setValue:signInData.providerName forKey:serverParams_provider];
        [dictionary setValue:signInData.externalServiceAccessToken forKey:serverParams_externalAccessToken];
       
    }
    

    [request setUpURLEncodeRequestTypeParamters:dictionary];
    
    NSURLSessionDataTask *dataTask = [[UtilityHelper defaultDownloadSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if (error) {
                [_signindelegate sessionManager:self signInCompleteWithNetworkError:error nativeErrorCode:SessionErrorCode_NetworkError forUser:signInData];
            }else {
                ApiResponseParser *parser = [ApiResponseParser new];
                //[parser parseData:downloader.mData networkStatusCode:downloader.networkStatusCode];
                NSHTTPURLResponse *httpCode = (NSHTTPURLResponse *)response;
                [parser parseData:data networkStatusCode:httpCode.statusCode];
                switch (parser.httpCode) {
                    case HttpCode_SignInSuccess:
                        if(parser.accessToken.length>0){
                            self.token = parser.accessToken;
                            self.refreshToken = parser.refreshToken;
                            self.tokenType  = parser.tokenType;
                            self.signedInUserID = parser.userName;
                            signInStatus        = UserSignInStatus_SignedIn;
                            // Save token
                            [self saveUserSignInInformation];
                            // Call Sign In Call back
                            [_signindelegate sessionManager:self signInCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_NoError forUser:signInData];
                        }
                        else{
                            // Log for exception
                            
                            // Call Sign In Failed call back, For now assuming it happened due to wrong user name password
                            [_signindelegate sessionManager:self signInCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_InternalServerError forUser:signInData];
                        }
                        break;
                        
                    case HttpCode_SignInMissingFields:
                    {
                        [_signindelegate sessionManager:self signInCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_MissingFields forUser:signInData];
                    }
                        break;
                        
                    case HttpCode_SignInInvalid:
                        
                    default:
                        // Call Sign In Failed call back, For now assuming it happened due to wrong user name password
                        [_signindelegate sessionManager:self signInCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_WrongEmailPassword forUser:signInData];
                        break;
                }
            }
        }];
    }];
    [dataTask resume];
    
    /// Start connection for request.
    //signinconnection = [[Downloader alloc] initWithRequest:request cachePolicy:0 delegate:self autoStartEnabled:YES];

}



-(void )signOutCurrentUser{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    signInStatus = UserSignInStatus_NotSignedIn;
    self.tokenType = nil;
    self.signedInUserID = nil;
    self.token = nil;
    self.refreshToken = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserSigOutFromApplicationNotification object:nil];
}


-(void )cancelSignUpProcess{
    [signupconnection cancel];
    signupconnection = nil;
}


- (void )renewSession{
    signInStatus = UserSignInStatus_RefereshingSignInToken;
    
    /// Prepare sign - up request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/token"]];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:self.refreshToken forKey:serverParams_refreshToken];
    [dictionary setValue:grantTypeRefreshLogin forKey:serverParams_grantType];
    [dictionary setValue:clientID forKey:serverParams_clientID];
    [request setUpURLEncodeRequestTypeParamters:dictionary];
    
    /// Start connection for request.
    
    refreshsignedintokenconnection = [[Downloader alloc] initWithRequest:request cachePolicy:0 delegate:self autoStartEnabled:YES];
    
}

-(NSMutableURLRequest *)requestForGetProfile{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/api/account/profile"]];
    [request setHTTPMethod:@"GET"];
    [request addValue:[[UserSessionManager sharedInstance] autherizationHeader]
   forHTTPHeaderField:autherizationHeaderKey];
    
    return request;
}

-(NSMutableURLRequest *)resetPasswordRequestForEmail:(NSString *)emailID{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/api/account/ResetPassword"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:emailID forKey:@"email"];
    [request setUpURLEncodeRequestTypeParamters:dictionary];
    return request;
}

-(NSMutableURLRequest *)authorizedPostRequest:(NSDictionary *)dictionary url:(NSURL *)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    #ifdef DEBUG
    NSLog(@"%s, %@",__func__,[dictionary description]);
    #endif
    
    [request setUpURLEncodeRequestTypeParamters:dictionary];
    [request addValue:[[UserSessionManager sharedInstance] autherizationHeader]
   forHTTPHeaderField:autherizationHeaderKey];

    return request;
}

-(NSMutableURLRequest *)authorizedLogoutRequest{
    return [self authorizedPostRequest:nil url:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/api/account/logout"]];
}


-(NSMutableURLRequest *)authorizeUpdateRequestForUser:(UserData *)userData{
    NSMutableDictionary*dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:userData.emailID forKey:serverParams_userName];
    [dictionary setValue:userData.emailID forKey:serverParams_email];
    [dictionary setValue:userData.firstName forKey:serverParams_firstName];
    [dictionary setValue:userData.lastName forKey:serverParams_lastName];
    [dictionary setValue:userData.phoneNumber forKey:serverParams_phoneNumber];
    [dictionary setValue:@"United Arab Emirates" forKey:serverParams_country];
    [dictionary setValue:userData.gender forKey:serverParams_gender];
    [dictionary setValue:userData.dobString    forKey:serverParams_birthDate];
    
    return [self authorizedPostRequest:dictionary url:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/api/account/profile"]];
}

-(NSString *)autherizationHeader;
{
    return [NSString stringWithFormat:@"%@ %@",_tokenType,_token];
}

//*****************************************************
#pragma mark - Downloader
//*****************************************************

-(void)downloader:(Downloader*)downloader errorDownloading:(NSError*)error
{
    if (downloader == signinconnection) {
        //[_signindelegate sessionManager:self signInCompleteWithNetworkError:error nativeErrorCode:SessionErrorCode_NetworkError];

    }else if (downloader == signupconnection) {
        //[_signupdelegate sessionManager:self signUpCompleteWithNetworkError:error nativeErrorCode:SessionErrorCode_NetworkError];
    }else if (downloader == refreshsignedintokenconnection) {
        [[NSNotificationCenter defaultCenter] postNotificationName:refreshTokenUpdateFailedNotification object:error];
    }
#ifdef DEBUG
    NSLog(@"%s, %@",__func__, [[NSString alloc] initWithData:downloader.mData encoding:NSUTF8StringEncoding]);
#endif
}

-(void)downloader:(Downloader*)downloader dataDownloadedDownloadedForLink:(NSURL*)link
{
    
    if (downloader == signinconnection)
    {
        
        
    }
    else
        if(downloader == signupconnection) {
            
            /*
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:downloader.mData options:0 error:nil];
        if ([response isKindOfClass:[NSString class]] || !response) {
            if ([(NSString *)response length] == 0) {
                response = [NSDictionary dictionary];
            }
        }
        if ([response isKindOfClass:[NSDictionary class]]) {
        
            if (response.allKeys.count == 0) {
                // Sign Up complete
                [_signupdelegate sessionManager:self signUpCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_NoError];

            }else {
                // Sign up failed
                [_signupdelegate sessionManager:self signUpCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_SomeErrorOccured];
            }
        
        }else {
            // Log for exception as internal server error, and tell user to try later

            // Call Sign up failed

            [_signupdelegate sessionManager:self signUpCompleteWithNetworkError:nil nativeErrorCode:SessionErrorCode_InternalServerError];
        }
        */
    }
    else
        if (downloader == refreshsignedintokenconnection) {
           // ApiResponseParser *parser = [ApiResponseParser new];
           // [parser parseData:downloader.mData networkStatusCode:downloader.networkStatusCode];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:downloader.mData options:0 error:nil];
            NSString *token         = response[serverResponseParams_accessToken];
            NSString *refreshToken  = response[serverResponseParams_refreshToken];
            NSString *tokenType     = response[serverResponseParams_tokenType];
            
            if (token.length>0) {
                self.token          = token;
                self.refreshToken   = refreshToken;
                self.signedInUserID = response[serverParams_userName];
                self.tokenType      = tokenType;
                signInStatus        = UserSignInStatus_SignedIn;
                
                // Save token
                [self saveUserSignInInformation];
                [[NSNotificationCenter defaultCenter] postNotificationName:refreshTokenUpdatedNotification object:nil];
            }else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:refreshTokenUpdateFailedNotification object:nil];
            }

        }
    
#ifdef DEBUG
    NSLog(@"%s, %@",__func__, [[NSString alloc] initWithData:downloader.mData encoding:NSUTF8StringEncoding]);
#endif
}


-(void)downloader:(Downloader*)downloader beginToDownloadLink:(NSURL*)link
{
#ifdef DEBUG
    NSLog(@"%s, %@",__func__, [[NSString alloc] initWithData:downloader.mData encoding:NSUTF8StringEncoding]);
#endif
}

-(void)downloader:(Downloader*)downloader dataDownloadProgress:(float)progress forLink:(NSURL*)link
{

}

//*****************************************************
#pragma mark - Target
//*****************************************************
//https://graph.facebook.com/me?access_token=
-(void )applicationDidBecomeActive:(NSNotification *)notification{
    if ([FacebookHelper sharedInstance].isUserLoggedIn && [UserSessionManager sharedInstance].token) {
        
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // Just to check facebook login status
            if(error){
                if (![FacebookHelper sharedInstance].isUserLoggedIn || [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                    
                    [[[UIAlertView alloc] initWithTitle:@"You have signed out of facebook. (development only alert)" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                    [[FacebookHelper sharedInstance] closeLoginSession];
                    
                    id <UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
                    UIWindow *window = [delegate window];
                    UIStoryboard *storyBoard = window.rootViewController.storyboard;
                    UIViewController *viewController = [storyBoard instantiateInitialViewController];
                    window.rootViewController = viewController;
                }
            }
        }];
    }
}

@end
