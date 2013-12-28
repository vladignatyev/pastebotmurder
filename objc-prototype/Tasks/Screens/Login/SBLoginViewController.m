//
// Created by Ринат Муртазин on 18.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBLoginViewController.h"
#import "AppDelegate.h"
#import "Mixpanel.h"


@implementation SBLoginViewController {

}

- (void)viewDidLoad {

    if([[DBAccountManager sharedManager] linkedAccount] && [[[DBAccountManager sharedManager] linkedAccount] isLinked]) {

        [self showMainScreen];
    }

    [[DBAccountManager sharedManager] addObserver:self block:^(DBAccount *account) {

        if(account && [account isLinked]) {

            [self showManualScreen];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[Mixpanel sharedInstance] track:@"open login screen"];
}

// user event

- (IBAction)loginButtonTapped:(UIButton *)sender {

    [[DBAccountManager sharedManager] linkFromController:self];
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


// system

- (void)showManualScreen {

    [self performSegueWithIdentifier:@"manualScreen" sender:self];
}

- (void)showMainScreen {

    [self performSegueWithIdentifier:@"mainScreen" sender:self];
}

@end