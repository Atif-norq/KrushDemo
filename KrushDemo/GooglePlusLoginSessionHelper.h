//
//  GooglePlusLoginSessionHelper.h
//  KrushDemo
//
//  Created by Atif Khan on 9/7/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>

extern NSString *const kGooglePlusNotificationSignedIn;
extern NSString *const kGooglePlusNotificationSignInErrorOccured;
extern NSString *const kGooglePlusNotificationUserReturnedBackWithOutAttemptToSignIn;

@interface GooglePlusLoginSessionHelper : NSObject<GPPSignInDelegate>
+(GooglePlusLoginSessionHelper *)sharedInstance;
-(void )attemptToSignInUser;

@end
