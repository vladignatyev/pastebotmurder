//
// Created by Ринат Муртазин on 19.12.13.
//

#import <Dropbox/Dropbox.h>
#import "SBSettingsViewController.h"


@implementation SBSettingsViewController {

}


- (void)viewDidLoad {

    [super viewDidLoad];

    _accountLabel.text = [DBAccountManager sharedManager].linkedAccount.info.displayName;
}

// user events

- (IBAction)didPressUnlink:(id)sender {

    [[[DBAccountManager sharedManager] linkedAccount] unlink];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)didTapClearDataButton:(id)sender {

    [[[UIAlertView alloc] initWithTitle:@"Clear data"
                               message:@"Are you sure?"
                              delegate:self
                     cancelButtonTitle:@"No"
                     otherButtonTitles:nil] show];

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
- (BOOL)shouldAutorotate{
    return NO;
}


@end