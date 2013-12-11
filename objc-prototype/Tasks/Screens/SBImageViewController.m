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



    [[SBImageManager manager] showImage:_imageName inImageView:_imageView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

// user events

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return _imageView;
}

- (IBAction)closeButtonPress:(id)sender {

    [self dismissModalViewControllerAnimated:YES];
}

@end