//
// Created by Ринат Муртазин on 19.12.13.
//

#import <Dropbox/Dropbox.h>
#import "SBSettingsViewController.h"


@implementation SBSettingsViewController {

}


// user events

- (IBAction)didPressUnlink:(id)sender {

    [[[DBAccountManager sharedManager] linkedAccount] unlink];

    [self.navigationController popToRootViewControllerAnimated:YES];
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