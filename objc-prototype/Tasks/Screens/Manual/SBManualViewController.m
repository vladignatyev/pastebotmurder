//
// Created by Ринат Муртазин on 27.12.13.
//

#import "SBManualViewController.h"
#import "Mixpanel.h"


@implementation SBManualViewController {

}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [[Mixpanel sharedInstance] track:@"open manual screen"];

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