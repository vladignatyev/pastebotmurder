//
// Created by Ринат Муртазин on 19.12.13.
//

#import <Dropbox/Dropbox.h>
#import "SBSettingsViewController.h"
#import "SBRecord.h"
#import "SBImageManager.h"
#import "AppKeys.h"
#import "Mixpanel.h"


@implementation SBSettingsViewController {

}


- (void)viewDidLoad {

    [super viewDidLoad];

    _accountLabel.text = [DBAccountManager sharedManager].linkedAccount.info.displayName;

    [[Mixpanel sharedInstance] track:@"open settings screen"];
}

// user events

- (IBAction)didPressUnlink:(id)sender {

    [[[DBAccountManager sharedManager] linkedAccount] unlink];

    [self.navigationController popToRootViewControllerAnimated:YES];

    [[Mixpanel sharedInstance] track:@"unlink account"];
}

- (IBAction)didTapClearDataButton:(id)sender {

    [[[UIAlertView alloc] initWithTitle:@"Clear data"
                                message:@"Are you sure?"
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil] show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {      //YES

        DBTable *bufsTbl = [self.store getTable:BUFS_TABLE];
        NSArray *records = [bufsTbl query:nil error:nil];

        for (DBRecord *record in records) {
            SBRecord *sbRecord = [SBRecord recordByDBRecord:record];
            if (sbRecord.isImage) {
                NSString *imagePath = sbRecord.value;
                SBImageManager *imageManager = [SBImageManager manager];
                [imageManager deleteImageByName:imagePath];
            }
            [sbRecord deleteRecord];
        }

        [self.navigationController popViewControllerAnimated:YES];

        [[Mixpanel sharedInstance] track:@"clear all data"];
    }
}


// Orientation


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return (orientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return NO;
}


@end