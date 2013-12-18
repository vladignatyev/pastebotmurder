//
// Created by Ринат Муртазин on 11.12.13.
//


#import <Foundation/Foundation.h>


@interface SBImageManager : NSObject

+ (SBImageManager *)manager;
- (void)deleteImageByName:(NSString *)name;

#ifdef SHOTBUF_IOS
- (void)showImage:(NSString *)imageName inImageView:(UIImageView *)imageView;
- (UIImage *)imageByName:(NSString *)name;
#endif

@end