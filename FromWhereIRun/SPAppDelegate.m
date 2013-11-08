//
//  SPAppDelegate.m
//  FromWhereIRun
//
//  Created by Leah Culver on 11/7/13.
//  Copyright (c) 2013 Spoetie. All rights reserved.
//

#import <Dropbox/Dropbox.h>

#import "SPAppDelegate.h"
#import "SPAuthViewController.h"
#import "SPRunListViewController.h"

@interface SPAppDelegate ()

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) SPAuthViewController *authViewController;

@end

@implementation SPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"3vd1skts4bpm221" secret:@"1r0gjas376qzg4g"];
    [DBAccountManager setSharedManager:accountManager];

    SPRunListViewController *runListViewController = [[SPRunListViewController alloc] initWithNibName:@"SPRunListViewController" bundle:nil];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:runListViewController];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    self.authViewController = [[SPAuthViewController alloc] initWithNibName:@"SPAuthViewController" bundle:nil];

    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account == nil) {
        [self.navigationController presentViewController:self.authViewController animated:NO completion:nil];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout)
                                                 name:SPLogoutNotification
                                               object:nil];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    
    if (account) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }

    return NO;
}

- (void)logout
{
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        [account unlink];
    }

    // Show auth screen
    [self.navigationController presentViewController:self.authViewController animated:YES completion:nil];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
    // Unregister for all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
