//
// Created by Ринат Муртазин on 11.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBImageManager.h"
#import "SBImageCell.h"


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

- (void)showImage:(NSString *)imageName inImageCell:(SBImageCell *)imageCell {

    [self performSelectorInBackground:@selector(showImageInImageCell:) withObject:@[imageCell, imageName]];
}

- (void)deleteImageByName:(NSString *)name {

    DBPath *existingPath = [[DBPath root] childPath:name];

    DBError *error = nil;

    [[DBFilesystem sharedFilesystem] deletePath:existingPath error:&error];
}

- (UIImage *)imageByName:(NSString *)name {

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

- (void)showImageInImageCell:(NSArray *)arguments {

    SBImageCell *imageCell = [arguments firstObject];

    NSString *imageName = [arguments lastObject];

    DBPath *existingPath = [[DBPath root] childPath:imageName];

    DBError *error = nil;

    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:&error];

    if (error) {

        if ([error code] == DBErrorParamsNotFound) {

            [file close];

            [NSThread sleepForTimeInterval:1];

            [self showImageInImageCell:arguments];
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

        [self performSelectorOnMainThread:@selector(setImageInImageCell:)
                               withObject:@[image, imageCell]
                            waitUntilDone:YES];
    }
}

- (void)setImageInImageCell:(NSArray *)arguments {

    UIImage *image = [arguments firstObject];

    SBImageCell *imageCell = [arguments lastObject];

    imageCell.mainImageView.image = image;

    imageCell.mainImageView.hidden = NO;

    [imageCell.activityIndicatorView stopAnimating];
}

@end