//
//  AppDelegate.m
//  KrushDemo
//
//  Created by Atif Khan on 8/28/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "GooglePlusLoginSessionHelper.h"

@implementation AppDelegate



// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
   
    BOOL handled = [[FacebookHelper sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:application];
    
    if (!handled) {
        handled = [GPPURLHandler handleURL:url
                         sourceApplication:sourceApplication
                                annotation:annotation];
    }
    return handled;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[FontHelper printAllFontsAvailable];
    BOOL initializeGooglePlusHandler = [GooglePlusLoginSessionHelper sharedInstance]?YES:NO;
    if (initializeGooglePlusHandler) {
        NSLog(@"Initialize google sign in handler");
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
