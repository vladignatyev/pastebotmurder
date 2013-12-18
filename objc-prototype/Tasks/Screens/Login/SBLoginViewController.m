//
// Created by Ринат Муртазин on 18.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBLoginViewController.h"
#import "AppDelegate.h"


@implementation SBLoginViewController {

}

- (void)viewDidLoad {

    if([[DBAccountManager sharedManager] linkedAccount] && [[[DBAccountManager sharedManager] linkedAccount] isLinked]) {

        [self showMainScreen];
    }

    [[DBAccountManager sharedManager] addObserver:self block:^(DBAccount *account) {

        if(account && [account isLinked]) {

            self.needShowNextScreen = YES;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    if(_needShowNextScreen) {

        self.needShowNextScreen = NO;

        [self showNextScreen];
    }
}

// user event

- (IBAction)loginButtonTapped:(UIButton *)sender {

    [[DBAccountManager sharedManager] linkFromController:self];
}


// system

- (void)showNextScreen {

    [self performSegueWithIdentifier:@"manualScreen" sender:self];
}

- (void)showMainScreen {

    [self performSegueWithIdentifier:@"mainScreen" sender:self];
}

@end