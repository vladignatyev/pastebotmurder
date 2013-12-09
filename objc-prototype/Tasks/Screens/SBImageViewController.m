//
// Created by Ринат Муртазин on 09.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBImageViewController.h"


@implementation SBImageViewController {

}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self performSelectorInBackground:@selector(functionWrapperShowImageInImageView:) withObject:@[_imageName, _imageView]];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return _imageView;
}


- (void)showImage:(NSString *)imageName inImageView:(UIImageView *)imageView {

    DBPath *existingPath = [[DBPath root] childPath:imageName];

    DBError *error = nil;

    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:&error];

    if (error) {

        if ([error code] == DBErrorParamsNotFound) {

            [file close];

            [NSThread sleepForTimeInterval:1];

            [self performSelector:@selector(functionWrapperShowImageInImageView:) withObject:@[imageName, imageView]];
        }

    } else {

        UIImage *image = [UIImage imageWithData:[file readData:nil]];

        while (image == nil) {

            [file close];

            [NSThread sleepForTimeInterval:0.5];

            file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];

            image = [UIImage imageWithData:[file readData:nil]];
        }

        [file close];

        [self performSelectorOnMainThread:@selector(setImageInImageView:)
                               withObject:@[image, imageView]
                            waitUntilDone:NO];
    }
}

- (void)functionWrapperShowImageInImageView:(NSArray *)arguments {

    [self showImage:[arguments firstObject] inImageView:[arguments lastObject]];
}

- (void)setImageInImageView:(NSArray *)arguments {

    UIImage *image = [arguments firstObject];

    UIImageView *imageView = [arguments lastObject];

    imageView.image = image;
}

- (IBAction)closeButtonPress:(id)sender {

    [self dismissModalViewControllerAnimated:YES];
}

@end