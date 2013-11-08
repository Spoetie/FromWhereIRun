//
//  SPRunViewController.m
//  FromWhereIRun
//
//  Created by Leah Culver on 11/7/13.
//  Copyright (c) 2013 Spoetie. All rights reserved.
//

#import "SPRunViewController.h"

@interface SPRunViewController () <UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) DBDatastore *store;
@property (strong, nonatomic) DBRecord *record;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
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
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"MM-dd-yyyy";
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Photo and date for edit mode
    if (self.record) {

        // Photo
        DBPath *path = [[DBPath root] childPath:self.record[@"imagePath"]];
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
        if (file) {
            NSData *data = [file readData:nil];
            self.image = [UIImage imageWithData:data];
            self.imageView.image = self.image;
        }

        // Date
        NSDate *date = self.record[@"date"];
        [self.datePicker setDate:date];

        // Share button
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareRun)];

    } else {
        [self.deleteButton setHidden:YES];
    }

    // Tap to add photo
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped)];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)imageViewTapped
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender
{
    /*
     * Photo is required to save run.
     */

    if (self.image == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Please select a photo for this run."
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    /*
     * Save photo to Dropbox app folder.
     */

    if (self.record && self.record[@"imagePath"]) {
        // Remove old photo - for this demo, simpler than modifying.
        DBPath *oldPath = [[DBPath root] childPath:self.record[@"imagePath"]];
        [[DBFilesystem sharedFilesystem] deletePath:oldPath error:nil];
    }

    DBPath *path = [self pathFromDatePicker]; // Ex: 11-05-2013.png
    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:path error:nil];
    [file writeData:UIImagePNGRepresentation(self.image) error:nil];
    [file close];

    /*
     * Update or create datastore record.
     */

    DBTable *table = [self.store getTable:@"runs"];

    if (self.record) {
        self.record[@"imagePath"] = path.name;
        self.record[@"date"] = self.datePicker.date;
    } else {
        NSDictionary *newRecord = @{@"imagePath": path.name, @"date": self.datePicker.date};
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
    if (buttonIndex != alertView.cancelButtonIndex) {
        // Delete photo
        DBPath *path = [[DBPath root] childPath:self.record[@"imagePath"]];
        [[DBFilesystem sharedFilesystem] deletePath:path error:nil];

        // Delete record
        [self.record deleteRecord];
        [self.store sync:nil];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerOriginalImage];
    [self.imageView setImage:self.image];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (DBPath *)pathFromDatePicker
{
    /*
     * Unique filename containing the date selected.
     * Ex: 11-05-2013.png or 11-05-2013 (1).png
     */

    DBPath *path = nil;
    NSString *filename = [NSString stringWithFormat:@"%@.png", [self.dateFormatter stringFromDate:self.datePicker.date]];
    int i = 1;

    while (path == nil) {
        // Check if this filename already exists.
        if ([[DBFilesystem sharedFilesystem] fileInfoForPath:[[DBPath root] childPath:filename] error:nil]) {
            filename = [NSString stringWithFormat:@"%@ (%d).png", [self.dateFormatter stringFromDate:self.datePicker.date], i];
            i++;
        } else {
            path = [[DBPath root] childPath:filename];
        }
    }

    return path;
}

- (void)shareRun
{
    if (self.record) {
        NSDate *date = self.record[@"date"];
        NSString *text = [NSString stringWithFormat:@"My run on %@ #fromWhereIRun", [self.dateFormatter stringFromDate:date]];

        DBPath *path = [[DBPath root] childPath:self.record[@"imagePath"]];
        NSString *urlString = [[DBFilesystem sharedFilesystem] fetchShareLinkForPath:path shorten:YES error:nil];
        NSURL *shareURL = [NSURL URLWithString:urlString];

        NSArray *activityItems = @[text, shareURL];

        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];

        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

@end
