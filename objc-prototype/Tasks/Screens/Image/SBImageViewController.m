//
// Created by Ринат Муртазин on 09.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBImageViewController.h"
#import "SBImageManager.h"
#import "Mixpanel.h"


@implementation SBImageViewController {

}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setUpTouch];

    [self setUpImage];

    [[Mixpanel sharedInstance] track:@"open" properties:@{@"type":@"image"}];
}

- (void)setUpTouch {

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];

    [_scrollView addGestureRecognizer:tap];


    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];

    [doubleTap setNumberOfTapsRequired:2];

    [_scrollView addGestureRecognizer:doubleTap];


    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap)];

    [_scrollView addGestureRecognizer:longTap];
}

- (void)setUpImage {

    UIImage *image = [[SBImageManager manager] imageByName:_imageName];

    if (image) {

        [_activityIndicator stopAnimating];

        CGRect frameForImageView = CGRectMake(0, 0, image.size.width, image.size.height);

        _imageView.frame = frameForImageView;

        _imageView.autoresizesSubviews = NO;

        _imageView.autoresizingMask = UIViewAutoresizingNone;

        _imageView.contentMode = UIViewContentModeCenter;

        _imageView.image = image;

        [_scrollView setZoomScale:1];

        [self calculateImageViewFrame];

    } else {

        [self performSelector:@selector(setUpImage) withObject:nil afterDelay:0.5];
    }
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}



// user events

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    [self calculateImageViewFrame];
}

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

- (void)longTap {

    [_scrollView setZoomScale:1 animated:YES];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [_scrollView sizeToFit];

    [self setUpImage];
}

// system

- (void)calculateImageViewFrame {

    CGSize currentImageSize = [self currentImageSize];
    CGSize viewSize = [self viewSize];

    CGRect frame = _imageView.frame;

    if (viewSize.width > currentImageSize.width) {

        frame.origin.x = (viewSize.width - currentImageSize.width) / 2;

    } else {

        frame.origin.x = 0;
    }

    if (viewSize.height > currentImageSize.height) {

        frame.origin.y = (viewSize.height - currentImageSize.height) / 2;

    } else {

        frame.origin.y = 0;
    }

    _imageView.frame = frame;
}

- (CGSize)currentImageSize {

    return CGSizeMake(_imageView.image.size.width * _scrollView.zoomScale, _imageView.image.size.height * _scrollView.zoomScale);
}

- (void)toggleNavBar {

    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (CGSize)viewSize {

    //return _scrollView.frame.size;

    float width = _scrollView.frame.size.width;
    float height = _scrollView.frame.size.height;

    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {

        if (width < height) {

            return CGSizeMake(height, width);
        }
    }

    return CGSizeMake(width, height);
}


@end