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

        CGSize screenSize = [self currentViewSize];

        BOOL imageMoreThenView = (image.size.width > screenSize.width || image.size.height > screenSize.height);

        _imageView.contentMode = (_imageFitMode && imageMoreThenView ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter);

        _imageView.image = image;

    } else {

        [self performSelector:@selector(setUpImage) withObject:nil afterDelay:1];
    }
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}



// user events

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return _imageView;
}

- (IBAction)closeButtonPress:(id)sender {

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)changeMode:(UISwitch *)sender {

    _imageFitMode = [sender isOn];

    [self setUpImage];
}

- (void)tap {

    [UIView animateWithDuration:0.5
                     animations:^() {

                         _menuView.alpha = !_menuView.alpha;
                     }];
}

- (void)doubleTap {

    _menuView.alpha = !_menuView.alpha;
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