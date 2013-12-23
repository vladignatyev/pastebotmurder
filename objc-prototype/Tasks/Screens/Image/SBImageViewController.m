//
// Created by Ринат Муртазин on 09.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBImageViewController.h"
#import "SBImageManager.h"


@implementation SBImageViewController {

}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setUpTouch];

    [self setUpImage];
}

- (void)setUpTouch {

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];

    [_scrollView addGestureRecognizer:tap];


    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];

    [doubleTap setNumberOfTapsRequired:2];

    [_scrollView addGestureRecognizer:doubleTap];
}

- (void)setUpImage {

    UIImage *image = [[SBImageManager manager] imageByName:_imageName];

    if (image) {

        [_activityIndicator stopAnimating];


        CGSize screenSize = [self currentViewSize];

        BOOL imageMoreThenView = (image.size.width > screenSize.width || image.size.height > screenSize.height);

        _imageView.contentMode = (imageMoreThenView ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter);

        if (imageMoreThenView) {

            float widthScale = image.size.width / screenSize.width;

            float heightScale = image.size.height / screenSize.height;

            [_scrollView setZoomScale:(widthScale > heightScale ? widthScale : heightScale)];
        }

        _imageView.image = image;

        /*
        NSLog(@"%@", @[[NSValue valueWithUIEdgeInsets:_scrollView.contentInset],
                [NSValue valueWithUIEdgeInsets:_scrollView.scrollIndicatorInsets],
                [NSValue valueWithCGSize:_scrollView.contentSize]]);

        _scrollView.contentSize = CGSizeMake(320, 568);
        */

    } else {

        [self performSelector:@selector(setUpImage) withObject:nil afterDelay:1];
    }
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}



// user events

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //[scrollView setContentOffset: CGPointMake(10, scrollView.contentOffset.y)];
}
*/

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return _imageView;
}

- (void)tap {

    self.timerForNavBar = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                           target:self
                                                         selector:@selector(toggleNavBar)
                                                         userInfo:nil
                                                          repeats:NO];

}

- (void)doubleTap {

    [_timerForNavBar invalidate];

    [_scrollView setZoomScale:_scrollView.zoomScale * 1.5 animated:YES];
}


// Autorotation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self setUpImage];
}

// system

- (void)toggleNavBar {

    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (CGSize)currentViewSize {

    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;

    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {

        return CGSizeMake(height, width);

    } else {

        return CGSizeMake(width, height);
    }
}


@end