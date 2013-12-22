//
//  SBPlainTextViewController.m
//  Datastore Examples
//
//  Created by Vladimir Ignatev on 11.12.13.
//
//

#import "SBPlainTextViewController.h"


@implementation SBPlainTextViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.textView.text = self.textToPresent;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    self.textView.delegate = nil;
}


// user events

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    BOOL statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];

    BOOL needStatusBar = (scrollView.contentInset.top + scrollView.contentOffset.y) <= 0;

    if(statusBarHidden == needStatusBar && !IS_iOS6) {

        [[UIApplication sharedApplication] setStatusBarHidden:!needStatusBar withAnimation:UIStatusBarAnimationSlide];
    }
}

@end
