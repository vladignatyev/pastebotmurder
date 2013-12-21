//
// Created by Ринат Муртазин on 19.12.13.
//

#import "SBNavigationController.h"


@implementation SBNavigationController {

}


- (void)viewDidLoad {

    [super viewDidLoad];

    if (IS_iOS6) {

        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarBG.png"]
                                                      forBarMetrics:UIBarMetricsDefault];

        [self.navigationBar setShadowImage:nil];

        self.navigationBar.tintColor = [UIColor colorWithRed:0 green:126/256.f blue:229/256.f alpha:1];

    }

}



-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end