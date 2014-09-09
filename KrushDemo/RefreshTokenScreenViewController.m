//
//  RefreshTokenScreenViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 9/3/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "RefreshTokenScreenViewController.h"
#import "TransitionDelegate.h"
#import "UserSessionManager.h"
#import "LoadActivityViewController.h"

@interface RefreshTokenScreenViewController ()

@property (strong, nonatomic) IBOutlet UILabel *accessToken;
@property (strong, nonatomic) IBOutlet UILabel *refreshToken;
@property (strong, nonatomic) IBOutlet UIView *sepratorView;
@property (nonatomic, strong) TransitionDelegate *transition;
@property (nonatomic, strong) LoadActivityViewController *loadingActivity;
@end

@implementation RefreshTokenScreenViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Tokens";
    
    _accessToken.text   = [UserSessionManager sharedInstance].token;
    _refreshToken.text  = [UserSessionManager sharedInstance].refreshToken;
    
    self.transition = [TransitionDelegate new];
    //LoadActivityViewController
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenUpdateNotification:) name:refreshTokenUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenUpdateFailedNotification:) name:refreshTokenUpdateFailedNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)refreshToken:(id)sender {
    
    self.loadingActivity = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadActivityViewController"];
    _loadingActivity.loadingMessage = @"Renewing tokens";
    _loadingActivity.modalPresentationStyle = UIModalPresentationCustom;
    _loadingActivity.transitioningDelegate = _transition;
    
    [self presentViewController:_loadingActivity animated:YES completion:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UserSessionManager sharedInstance] renewSession];
        }];
    }];
}

-(void )tokenUpdateNotification:(NSNotification *)notification{
    _accessToken.text   = [UserSessionManager sharedInstance].token;
    _refreshToken.text  = [UserSessionManager sharedInstance].refreshToken;
    
    [_loadingActivity dismissViewControllerAnimated:YES completion:NULL];
    self.loadingActivity = nil;
}

-(void )tokenUpdateFailedNotification:(NSNotification *)notification{
    [[[UIAlertView alloc] initWithTitle:@"Failed to renew tokens" message:@"You can try again." delegate:nil cancelButtonTitle:@"Ok." otherButtonTitles: nil] show];
    [_loadingActivity dismissViewControllerAnimated:YES completion:NULL];
    self.loadingActivity = nil;
}

- (IBAction)logout:(id)sender {
    NSURLRequest *request = [[UserSessionManager sharedInstance] authorizedLogoutRequest];
    
    NSURLSession *logoutSession = [UtilityHelper defaultDownloadSession];
    NSURLSessionDownloadTask *downloadTask = [logoutSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        //NSURLResponse *response = nil;
        //NSError *error = nil;
        
        if (error) {
            NSLog(@"Error :%@",error.localizedDescription);
        }else {
            NSData *dowloadedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            ApiResponseParser *parser = [ApiResponseParser new];
            [parser parseData:dowloadedData networkStatusCode:httpResponse.statusCode];
            
            switch (parser.httpCode) {
                case HttpCode_Success:
                {
                    NSLog(@"Log out");
                }
                    break;
                    
                default:{
                    NSLog(@"Logout failed : %@",[[NSString alloc] initWithData:dowloadedData encoding:NSUTF8StringEncoding]);
                }
                    break;
            }
        }
    }];
    [downloadTask resume];
    /*
    [[UtilityHelper sharedOperationQueue] addOperationWithBlock:^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *dowloadedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        ApiResponseParser *parser = [ApiResponseParser new];
        [parser parseData:dowloadedData networkStatusCode:httpResponse.statusCode];
        
        switch (parser.httpCode) {
            case HttpCode_Success:
            {
                NSLog(@"Log out");
            }
                break;
                
            default:{
                NSLog(@"Logout failed : %@",[[NSString alloc] initWithData:dowloadedData encoding:NSUTF8StringEncoding]);
            }
                break;
        }
    }];
    */
    
    [[UserSessionManager sharedInstance] signOutCurrentUser];
    id <UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = [delegate window];
    UIStoryboard *storyBoard = window.rootViewController.storyboard;
    UIViewController *viewController = [storyBoard instantiateInitialViewController];
    UIViewController *oldVC = window.rootViewController;
    [UIView transitionFromView:oldVC.view toView:viewController.view duration:.5 options:UIViewAnimationOptionTransitionCurlUp|UIViewAnimationOptionCurveEaseOut completion:^(BOOL finished) {
        window.rootViewController = viewController;
    }];
}
@end
