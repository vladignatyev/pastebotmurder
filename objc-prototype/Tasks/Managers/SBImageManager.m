//
// Created by Ринат Муртазин on 11.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBImageManager.h"


@implementation SBImageManager {

}

+ (SBImageManager *)manager {

    static SBImageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SBImageManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)showImage:(NSString *)imageName inImageView:(UIImageView *)imageView {

    [self performSelectorInBackground:@selector(showImageInImageView:) withObject:@[imageView, imageName]];
}


- (UIImage *)imageByImageName:(NSString *)name {

    DBPath *existingPath = [[DBPath root] childPath:name];

    DBError *error = nil;

    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:&error];

    UIImage *result = nil;

    if (!error) {

        if (file.status.cached) {

            result = [UIImage imageWithData:[file readData:nil]];
        }
    }

    [file close];

    return result;
}

- (void)showImageInImageView:(NSArray *)arguments {

    UIImageView *imageView = [arguments firstObject];

    NSString *imageName = [arguments lastObject];

    DBPath *existingPath = [[DBPath root] childPath:imageName];

    DBError *error = nil;

    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:&error];

    if (error) {

        if ([error code] == DBErrorParamsNotFound) {

            [file close];

            [NSThread sleepForTimeInterval:1];

            [self showImageInImageView:arguments];
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
                            waitUntilDone:YES];
    }
}

- (void)setImageInImageView:(NSArray *)arguments {

    UIImage *image = [arguments firstObject];

    UIImageView *imageView = [arguments lastObject];

    imageView.image = image;

    imageView.hidden = NO;
}

@end