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

    [self setUpImage];
}

- (void)setUpImage {

    UIImage *image = [[SBImageManager manager] imageByName:_imageName];

    if(image) {

        CGSize screenSize = [self currentScreenSize];

//        if(image.size.width > screenSize.width || image.size.height > screenSize.height) {
//
//            _imageView.contentMode = UIViewContentModeScaleAspectFit;
//
//        } else {

            _imageView.contentMode = UIViewContentModeCenter;
//        }

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

// Autorotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}



- (BOOL)shouldAutorotate
{
    return YES;
}


// system

- (CGSize)currentScreenSize {
    
    return CGSizeMake(320, 480);
}

@end