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


    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap)];

    [_scrollView addGestureRecognizer:longTap];
}

- (void)setUpImage {

    UIImage *image = [[SBImageManager manager] imageByName:_imageName];

    if (image) {

        [_activityIndicator stopAnimating];

        /*

        CGSize screenSize = [self viewSize];

        BOOL imageMoreThenView = (image.size.width > screenSize.width || image.size.height > screenSize.height);

        _imageView.contentMode = (imageMoreThenView ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter);

        _imageScale = 1;

        if (imageMoreThenView) {

            float widthScale = image.size.width / screenSize.width;

            float heightScale = image.size.height / screenSize.height;

            _imageScale = (widthScale > heightScale ? widthScale : heightScale);

            [_scrollView setZoomScale:_imageScale];

            _imageView.image = image;
        }

        */

        /*

        BOOL imageMoreThenView = (image.size.width >= screenSize.height || image.size.height >= screenSize.height);

        imageMoreThenView = YES;

        if(imageMoreThenView) {

            CGRect frameForImageView = CGRectMake(0, 0, image.size.width, image.size.height);

            _imageView.frame = frameForImageView;

            _imageView.contentMode = UIViewContentModeCenter;

            _imageView.image = image;

            [_scrollView setZoomScale:1];

        } else {

            _imageView.contentMode = UIViewContentModeScaleAspectFit;

            _imageView.image = image;

            [_scrollView setZoomScale:1];
        }

        */

        CGRect frameForImageView = CGRectMake(0, 0, image.size.width, image.size.height);

        _imageView.frame = frameForImageView;

        _imageView.contentMode = UIViewContentModeCenter;

        _imageView.image = image;

        [_scrollView setZoomScale:1];

        [self calculateImageViewPoint];

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

    [self calculateImageViewPoint];
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

// system

- (void)calculateImageViewPoint {

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

    //NSLog(@"%f %f %@", viewSize.width, currentImageSize.width, [NSValue valueWithCGRect:frame]);
}

- (CGSize)currentImageSize {

    return CGSizeMake(_imageView.image.size.width * _scrollView.zoomScale, _imageView.image.size.height * _scrollView.zoomScale);
}

- (void)toggleNavBar {

    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (CGSize)viewSize {

    return self.view.frame.size;

    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;

    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {

        return CGSizeMake(height, width);

    } else {

        return CGSizeMake(width, height);
    }
}


@end