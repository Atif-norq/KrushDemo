//
//  GooglePlusLoadActivityViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 9/7/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "GooglePlusLoadActivityViewController.h"
#import "GooglePlusLoginSessionHelper.h"


@interface GooglePlusLoadActivityViewController ()

@end

@implementation GooglePlusLoadActivityViewController

-(void )attemptToLoginToGoogle{
    [[GooglePlusLoginSessionHelper sharedInstance] attemptToSignInUser];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void )addGoogleHelperNotificationCallBacks{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(googlePlusUserSignedIn:) name:kGooglePlusNotificationSignedIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(googlePlusUserSignedInErrorOccured:) name:kGooglePlusNotificationSignInErrorOccured object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(googlePlusUserReturenedWithOutAttemptToSignIn:) name:kGooglePlusNotificationUserReturnedBackWithOutAttemptToSignIn object:nil];
    
}

-(void)viewDidLoad{

    [super viewDidLoad];
    [self addGoogleHelperNotificationCallBacks];
    
    self.loadingMessage = @"Signing to Google+...";
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self attemptToLoginToGoogle];
}


//*****************************************************
#pragma mark - Notifications
//*****************************************************

-(void )googlePlusUserSignedIn:(NSNotification *)sender{
    [[[UIAlertView alloc] initWithTitle:@"User signed in with google+" message:@"Since in back end Google+ provider is not added, currently we cannot proced with sign in with to shopex server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void )googlePlusUserSignedInErrorOccured:(NSNotification *)sender{
    NSError *error = sender.object;
    [[[UIAlertView alloc] initWithTitle:@"Failed to sign in with google+" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void )googlePlusUserReturenedWithOutAttemptToSignIn:(NSNotification *)sender{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
