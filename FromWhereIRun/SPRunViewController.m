//
//  SPRunViewController.m
//  FromWhereIRun
//
//  Created by Leah Culver on 11/7/13.
//  Copyright (c) 2013 Spoetie. All rights reserved.
//

#import "SPRunViewController.h"

@interface SPRunViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) DBDatastore *store;
@property (strong, nonatomic) DBRecord *record;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation SPRunViewController

- (id)initWithWithDatastore:(DBDatastore *)store
{
    return [self initWithWithDatastore:store record:nil];
}

- (id)initWithWithDatastore:(DBDatastore *)store record:(DBRecord *)record
{
    self = [super initWithNibName:@"SPRunViewController" bundle:nil];

    if (self) {
        self.store = store;
        self.record = record;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Defaults for edit mode
    if (self.record) {
        NSDate *date = self.record[@"date"];
        [self.datePicker setDate:date];
    } else {
        [self.deleteButton setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender
{
    DBTable *table = [self.store getTable:@"runs"];

    if (self.record) {
        self.record[@"date"] = self.datePicker.date;
    } else {
        NSDictionary *newRecord = @{@"date": self.datePicker.date};
        [table insert:newRecord];
    }

    [self.store sync:nil];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Are you sure you want to\ndelete this run?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes, delete!", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self.record deleteRecord];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
