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


        CGSize screenSize = [self viewSize];

        BOOL imageMoreThenView = (image.size.width > screenSize.width || image.size.height > screenSize.height);

        _imageView.contentMode = (imageMoreThenView ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter);

        _imageScale = 1;

        if (imageMoreThenView) {

            float widthScale = image.size.width / screenSize.width;

            float heightScale = image.size.height / screenSize.height;

            _imageScale = (widthScale > heightScale ? widthScale : heightScale);

            [_scrollView setZoomScale:_imageScale];
        }

        _imageView.image = image;


    } else {

        [self performSelector:@selector(setUpImage) withObject:nil afterDelay:1];
    }
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    _needProssingScroll = YES;

    [self setContentOffsetLeftTop];
}



// user events

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //return;

    if (!_needProssingScroll) {

        return;
    }

    CGSize imageSize = [self currentImageSize];

    CGSize viewSize = [self viewSize];

    //NSLog(@"%@", [NSValue valueWithCGSize:viewSize]);

    if (imageSize.width >= viewSize.width && imageSize.width <= imageSize.height) {

        CGSize startImageSize = [self startImageSize];

        float scale = _scrollView.zoomScale;

        CGPoint contentOffset = CGPointMake(_scrollView.contentOffset.x / scale, _scrollView.contentOffset.y / scale);

        float imageWidthPadding = (viewSize.width - startImageSize.width) / 2;

        if (imageWidthPadding > contentOffset.x) {

            [_scrollView setContentOffset:CGPointMake(imageWidthPadding * scale, _scrollView.contentOffset.y)];

        } else {

            CGSize currentViewScaleSize = CGSizeMake(viewSize.width / scale, viewSize.height / scale);

            float rightPadding = viewSize.width - imageWidthPadding;

            if (contentOffset.x + currentViewScaleSize.width > rightPadding) {

                [_scrollView setContentOffset:CGPointMake((rightPadding - currentViewScaleSize.width) * scale, _scrollView.contentOffset.y)];
            }
        }

    } else if (imageSize.height >= viewSize.height && imageSize.height <= imageSize.width) {

        CGSize startImageSize = [self startImageSize];

        float scale = _scrollView.zoomScale;

        CGPoint contentOffset = CGPointMake(_scrollView.contentOffset.x / scale, _scrollView.contentOffset.y / scale);

        float imageHeightPadding = (viewSize.height - startImageSize.height) / 2;

        if (imageHeightPadding > contentOffset.y) {

            [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x, imageHeightPadding * scale)];

        } else {

            CGSize currentViewScaleSize = CGSizeMake(viewSize.width / scale, viewSize.height / scale);

            float bottomPadding = viewSize.height - imageHeightPadding;

            if (contentOffset.y + currentViewScaleSize.height > bottomPadding) {

                [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x, (bottomPadding - currentViewScaleSize.height) * scale)];
            }
        }
    }

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

- (void)setContentOffsetLeftTop {

    CGSize viewSize = [self viewSize];

    CGSize startImageSize = [self startImageSize];

    CGSize imageSize = [self currentImageSize];

    float scale = _scrollView.zoomScale;

    if (imageSize.height > viewSize.height) {

        float imageHeightPadding = (viewSize.height - startImageSize.height) / 2;

        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x, imageHeightPadding * scale)];
    }

    if (imageSize.width > viewSize.width) {

        float imageWidthPadding = (viewSize.width - startImageSize.width) / 2;

        [_scrollView setContentOffset:CGPointMake(imageWidthPadding * scale, _scrollView.contentOffset.y)];

    }
}

- (CGSize)currentImageSize {

    return CGSizeMake(_imageView.image.size.width * _scrollView.zoomScale / _imageScale, _imageView.image.size.height * _scrollView.zoomScale / _imageScale);
}

- (CGSize)startImageSize {

    return CGSizeMake(_imageView.image.size.width / _imageScale, _imageView.image.size.height / _imageScale);
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