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
    /*
     * Setup account manager with app key and secret.
     */

    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"3vd1skts4bpm221" secret:@"1r0gjas376qzg4g"];
    [DBAccountManager setSharedManager:accountManager];

    /*
     * Setup view controllers.
     */

    SPRunListViewController *runListViewController = [[SPRunListViewController alloc] initWithNibName:@"SPRunListViewController" bundle:nil];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:runListViewController];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    /*
     * Auth view controller for connecting with Dropbox.
     */

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

- (void)dealloc
{
    // Unregister for all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
