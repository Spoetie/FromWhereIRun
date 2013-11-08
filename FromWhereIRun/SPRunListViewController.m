//
//  SPRunListViewController.m
//  FromWhereIRun
//
//  Created by Leah Culver on 11/7/13.
//  Copyright (c) 2013 Spoetie. All rights reserved.
//

#import <Dropbox/Dropbox.h>

#import "SPRunListViewController.h"
#import "SPRunViewController.h"

NSString * const SPLogoutNotification = @"SPLogoutNotification";

@interface SPRunListViewController ()

@property (strong, nonatomic) DBDatastore *store;
@property (strong, nonatomic) NSArray *runs;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation SPRunListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"From Where I Run";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
}

- (void)viewWillAppear:(BOOL)animated
{
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {

        if ([DBFilesystem sharedFilesystem] == nil) {
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
        }

        if (self.store == nil) {
            self.store = [DBDatastore openDefaultStoreForAccount:account error:nil];
        }

        DBTable *table = [self.store getTable:@"runs"];

        // Display all runs
        self.runs = [table query:nil error:nil];

        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.runs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RunCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    DBRecord *record = self.runs[indexPath.row];

    DBPath *path = [[DBPath root] childPath:record[@"imagePath"]];
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
    if (file) {
        NSData *data = [file readData:nil];
        cell.imageView.image = [UIImage imageWithData:data];
    }

    NSDate *date = record[@"date"];
    if (self.dateFormatter == nil) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"MMMM d yyyy";
    }
    cell.textLabel.text = [self.dateFormatter stringFromDate:date];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBRecord *record = self.runs[indexPath.row];
    SPRunViewController *runViewController = [[SPRunViewController alloc] initWithWithDatastore:self.store record:record];
    [self.navigationController pushViewController:runViewController animated:YES];
}

- (void)addButtonPressed
{
    SPRunViewController *runViewController = [[SPRunViewController alloc] initWithWithDatastore:self.store];
    [self.navigationController pushViewController:runViewController animated:YES];
}

- (void)logoutButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPLogoutNotification object:self];
}

@end
