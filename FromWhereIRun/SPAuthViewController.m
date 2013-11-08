//
//  SPAuthViewController.m
//  FromWhereIRun
//
//  Created by Leah Culver on 11/7/13.
//  Copyright (c) 2013 Spoetie. All rights reserved.
//

#import "SPAuthViewController.h"

@implementation SPAuthViewController

- (IBAction)connectButtonPressed:(id)sender
{
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account) {
        NSLog(@"App already linked");
    } else {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}

@end
