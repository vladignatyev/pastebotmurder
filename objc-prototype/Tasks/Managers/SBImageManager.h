//
// Created by Ринат Муртазин on 11.12.13.
//


#import <Foundation/Foundation.h>


@interface SBImageManager : NSObject

+ (SBImageManager *)manager;

- (void)showImage:(NSString *)imageName inImageView:(UIImageView *)imageView;

- (UIImage *)imageByName:(NSString *)name;

- (void)deleteImageByName:(NSString *)name;

@end