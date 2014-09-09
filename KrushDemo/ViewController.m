//
//  ViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 8/28/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "ViewController.h"
#import "AppLauncherScreen.h"
#import "LoadActivityViewController.h"
#import "FacebookUserInfoFetcherViewController.h"
#import "GooglePlusLoginSessionHelper.h"
#import "TransitionDelegate.h"
#import "UserSessionManager.h"
#import "ExternalSignInDataEntryViewController.h"

typedef enum {
    AppLaucherState_Default = 0,
    AppLaucherState_SignMenu
}AppLauncherState;


@interface ViewController ()<FacebookUserInforamtion>
// Default State Views
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *orsepratorviews;
@property (strong, nonatomic) IBOutlet UIButton *demoButton;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIButton *signInWithEmail;
@property (strong, nonatomic) IBOutlet UIButton *signInWithTwitter;
@property (strong, nonatomic) IBOutlet UIButton *signInWithGooglePlus;

@property (strong, nonatomic) IBOutlet UIButton *signInWithFacebook;
@property (strong, nonatomic) IBOutlet UILabel *applicationName;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, assign) AppLauncherState viewState;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, strong) UIViewController *modelVC;
@property (nonatomic, strong) TransitionDelegate *transitionHelper;

@end

@implementation ViewController

-(void )userSignedOut:(NSNotification *)notification{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void )addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedOut:) name:UserSigOutFromApplicationNotification object:nil];
}

-(void )addGradientOverlayLayer{
    CAGradientLayer *layer = [CAGradientLayer layer];
    self.gradientLayer  = layer;
    layer.startPoint    = CGPointMake(.5, 0.f);
    layer.endPoint      = CGPointMake(.5f, 1.f);
    layer.colors        = @[    (id)[[UIColor clearColor] CGColor],
                             (id)[getColorForRGBA(0, 0, 0, .4) CGColor]];
    [_overlayView.layer insertSublayer:layer atIndex:0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    SKView *skView          = (SKView *)self.view;
    skView.paused           = NO;
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    SKView *skView          = (SKView *)self.view;
    skView.paused           = YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotification];
    
    self.transitionHelper = [TransitionDelegate new];
    
     _signInWithEmail.titleLabel.font = _signInWithFacebook.titleLabel.font = _signInWithGooglePlus.titleLabel.font = _signInButton.titleLabel.font = [FontHelper fontProximaBoldSize:22];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _hSpacingEmailButton.constant = _hSpacingTwitterButton.constant = _hSpacingFacebookButton.constant = 320;
    
    SKView *skView          = (SKView *)self.view;
    skView.showsFPS         = NO;
    skView.showsNodeCount   = NO;


    // Set Fonts
    self.applicationName.font = [UIFont fontWithName:@"NeuzeitSLTStd-BookHeavy" size:30];
    
    // Add gradient overlay layer
    [self addGradientOverlayLayer];
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        SKScene *scene = [AppLauncherScreen sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeResizeFill;
        [skView presentScene:scene];
        [(AppLauncherScreen *)scene prePopulateNodes];
    }
    
    // Update gradient size;
    _gradientLayer.frame = self.view.bounds;
    
}


- (IBAction)signInToShopexClicked:(id)sender {
    [self showLauncherMenuWithAnimation];
}

// Animations
-(void )showLauncherMenuWithAnimation{
    [self.overlayView layoutIfNeeded];
    

    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionAllowUserInteraction || UIViewAnimationOptionCurveEaseInOut  animations:^{
        
        CGAffineTransform transform = CGAffineTransformMakeScale(.8, .8);
        
        _signInButton.transform                     = transform;
        _demoButton.transform                       = transform;
        //((UIView *)_orsepratorviews[0]).transform   = transform;
        //((UIView *)_orsepratorviews[1]).transform   = transform;
        //((UIView *)_orsepratorviews[2]).transform   = transform;
        
        _signInButton.alpha                     = 0;
        _demoButton.alpha                       = 0;
        ((UIView *)_orsepratorviews[0]).alpha   = 0;
        ((UIView *)_orsepratorviews[1]).alpha   = 0;
        ((UIView *)_orsepratorviews[2]).alpha   = 0;

    } completion:^(BOOL finished) {
        
         // Facebook
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.95 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.hSpacingFacebookButton.constant = 0;
            [self.overlayView layoutSubviews];
        } completion:^(BOOL finished) {
        }];

        
        // Twitter
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.hSpacingTwitterButton.constant = 0;
            [self.overlayView layoutSubviews];
            _backButton.alpha = 1.f;
        } completion:^(BOOL finished) {
        }];
        
        // Mail
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.hSpacingEmailButton.constant = 0;
            [self.overlayView layoutSubviews];
        } completion:^(BOOL finished) {
            [self.overlayView layoutSubviews];

        }];
        
    }];
    
    
    

}


- (IBAction)goToDefaultState:(id)sender {
    [self.overlayView layoutIfNeeded];

    int selfWidth = self.view.bounds.size.width;
    // Facebook
    [UIView animateWithDuration:.9 delay:0 usingSpringWithDamping:.95 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.hSpacingFacebookButton.constant = selfWidth;
        [self.overlayView layoutSubviews];
        _backButton.alpha = 0.f;
    } completion:^(BOOL finished) {
        
    }];
    
    // Twitter
    [UIView animateWithDuration:.9 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.hSpacingTwitterButton.constant = selfWidth;
        [self.overlayView layoutSubviews];
    } completion:^(BOOL finished) {}];
    
    // Mail
    [UIView animateWithDuration:.9 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.hSpacingEmailButton.constant = selfWidth;
        [self.overlayView layoutSubviews];
    } completion:^(BOOL finished) {
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.7 delay:0. usingSpringWithDamping:.7 initialSpringVelocity:8 options:UIViewAnimationOptionBeginFromCurrentState|| UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1.f, 1.f);
            
            _signInButton.transform                     = transform;
            _demoButton.transform                       = transform;
            //((UIView *)_orsepratorviews[0]).transform   = transform;
            //((UIView *)_orsepratorviews[1]).transform   = transform;
            //((UIView *)_orsepratorviews[2]).transform   = transform;
            
            float alpha                             = 1;
            _signInButton.alpha                     = alpha;
            _demoButton.alpha                       = alpha;
            ((UIView *)_orsepratorviews[0]).alpha   = alpha;
            ((UIView *)_orsepratorviews[1]).alpha   = alpha;
            ((UIView *)_orsepratorviews[2]).alpha   = alpha;
        } completion:^(BOOL finished) {
            [self.overlayView layoutIfNeeded];
            
        }];
    });
    
    
}

- (IBAction)signInWihtFacebook:(id)sender {
    
    FacebookUserInfoFetcherViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FacebookUserInfoFetcherViewController"];
    self.modelVC = vc;
    vc.delegate = self;
    vc.loadingMessage = @"";
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = _transitionHelper;
    [self presentViewController:vc animated:YES completion:NULL];
}

- (IBAction)signInWithGooglePlus:(id)sender {
    
    LoadActivityViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GooglePlusLoadActivityViewController"];
    self.modelVC = vc;
//    vc.delegate = self;
    vc.loadingMessage = @"";
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = _transitionHelper;
    
    [self presentViewController:vc animated:YES completion:NULL];
}

//*****************************************************
#pragma mark - Facebook User info
//*****************************************************

-(void )facebookUserInformationVC:(FacebookUserInfoFetcherViewController *)sender failedToGetUserInfoWithError:(NSError *)error{
    [sender dismissViewControllerAnimated:YES completion:NULL];
    [[[UIAlertView alloc] initWithTitle:@"Unable to get details." message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    
    self.modelVC = nil;

}

-(void )facebookUserInformationVC:(FacebookUserInfoFetcherViewController *)sender userInfo:(NSDictionary *)dictionary{
   
}

-(BOOL )facebookUserInformationVCShouldAttemptToLoginNatively:(FacebookUserInfoFetcherViewController *)sender{
    return YES;
}

-(void )facebookUserInformationVCLoginCanceledByUser:(FacebookUserInfoFetcherViewController *)sender{
    [sender dismissViewControllerAnimated:YES completion:NULL];
    self.modelVC = nil;
    
}

-(void )facebookUserInformationVCUserSignedNatively:(FacebookUserInfoFetcherViewController *)sender{
    [sender dismissViewControllerAnimated:YES completion:^{
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RefreshTokenScreenViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    self.modelVC = nil;
}

-(void)facebookUserInformationVCUserSignedNativelyMissingField:(FacebookUserInfoFetcherViewController *)sender userData:(UserData *)uData{
    [sender dismissViewControllerAnimated:NO completion:^{
        ExternalSignInDataEntryViewController *vc = (ExternalSignInDataEntryViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ExternalSignInDataEntryViewController"];
        vc.userData = uData;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    self.modelVC = nil;
}

-(void)facebookUserInformationVC:(FacebookUserInfoFetcherViewController *)sender failedToLoginToFB:(NSError *)error{
    [sender dismissViewControllerAnimated:YES completion:NULL];
    self.modelVC = nil;
}

-(void )facebookUserInformationVCUserSignedNatively:(FacebookUserInfoFetcherViewController *)sender failedWithError:(NSError *)error{
    [sender dismissViewControllerAnimated:YES completion:NULL];
    self.modelVC = nil;
}

-(void )facebookUserSignedOut:(FacebookUserInfoFetcherViewController *)sender{
    [sender dismissViewControllerAnimated:YES completion:NULL];
    self.modelVC = nil;

}
@end
