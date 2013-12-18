//
// Created by Ринат Муртазин on 11.12.13.
//


#import <Foundation/Foundation.h>

@class SBImageCell;

@interface SBImageManager : NSObject

+ (SBImageManager *)manager;

- (void)showImage:(NSString *)imageName inImageCell:(SBImageCell *)imageCell;

- (UIImage *)imageByName:(NSString *)name;

- (void)deleteImageByName:(NSString *)name;

@end