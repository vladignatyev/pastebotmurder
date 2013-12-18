//
// Created by Ринат Муртазин on 18.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBLoginViewController.h"
#import "AppDelegate.h"


@implementation SBLoginViewController {

}

- (void)viewDidLoad {

    [[DBAccountManager sharedManager] addObserver:self block:^(DBAccount *account) {

        if(account && [account isLinked]) {

            [self showMainScreen];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

// user event

- (IBAction)loginButtonTapped:(UIButton *)sender {

    [[DBAccountManager sharedManager] linkFromController:self];
}


// system

- (void)showMainScreen {

    [self dismissViewControllerAnimated:NO completion:nil];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];

    UIViewController *main = [storyboard instantiateViewControllerWithIdentifier:@"main"];

    main.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [self presentViewController:main animated:YES completion:nil];
}

@end