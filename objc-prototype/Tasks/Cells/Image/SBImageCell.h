//
// Created by Ринат Муртазин on 05.12.13.
//


#import <Foundation/Foundation.h>
#import "SBBaseCell.h"


@interface SBImageCell : SBBaseCell

@property (nonatomic, strong) IBOutlet UIImageView *mainImageView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end