//
//  SPRunViewController.h
//  FromWhereIRun
//
//  Created by Leah Culver on 11/7/13.
//  Copyright (c) 2013 Spoetie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface SPRunViewController : UIViewController

- (id)initWithWithDatastore:(DBDatastore *)store;
- (id)initWithWithDatastore:(DBDatastore *)store record:(DBRecord *)record;

@end
