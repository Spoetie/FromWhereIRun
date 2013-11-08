//
//  SPRunViewController.m
//  FromWhereIRun
//
//  Created by Leah Culver on 11/7/13.
//  Copyright (c) 2013 Spoetie. All rights reserved.
//

#import <Dropbox/Dropbox.h>

#import "SPRunViewController.h"

@interface SPRunViewController ()

@property (strong, nonatomic) DBDatastore *store;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation SPRunViewController

- (id)initWithWithDatastore:(DBDatastore *)store
{
    self = [super initWithNibName:@"SPRunViewController" bundle:nil];

    if (self) {
        self.store = store;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender
{
    DBTable *table = [self.store getTable:@"runs"];

    [table insert:@{@"date": self.datePicker.date}];

    [self.store sync:nil];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
