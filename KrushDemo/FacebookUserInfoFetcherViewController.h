//
//  FacebookUserInfoFetcherViewController.h
//  KrushDemo
//
//  Created by Atif Khan on 9/3/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "LoadActivityViewController.h"
@class FacebookUserInfoFetcherViewController;

@protocol FacebookUserInforamtion <NSObject>

-(void )facebookUserInformationVC:(FacebookUserInfoFetcherViewController *)sender failedToGetUserInfoWithError:(NSError *)error;
-(void )facebookUserInformationVC:(FacebookUserInfoFetcherViewController *)sender userInfo:(NSDictionary *)dictionary;

-(BOOL )facebookUserInformationVCShouldAttemptToLoginNatively:(FacebookUserInfoFetcherViewController *)sender;
-(void )facebookUserInformationVC:(FacebookUserInfoFetcherViewController *)sender failedToLoginToFB:(NSError *)error;
-(void )facebookUserInformationVCLoginCanceledByUser:(FacebookUserInfoFetcherViewController *)sender;


-(void )facebookUserInformationVCUserSignedNativelyMissingField:(FacebookUserInfoFetcherViewController *)sender userData:(UserData *)uData;
-(void )facebookUserInformationVCUserSignedNatively:(FacebookUserInfoFetcherViewController *)sender;
-(void )facebookUserInformationVCUserSignedNatively:(FacebookUserInfoFetcherViewController *)sender failedWithError:(NSError *)error;
-(void )facebookUserSignedOut:(FacebookUserInfoFetcherViewController *)sender;

@end

@interface FacebookUserInfoFetcherViewController : LoadActivityViewController
@property (nonatomic, strong) id<FacebookUserInforamtion>delegate;
@property (nonatomic, strong) UserData *userData;
@end
