//
// Created by Ринат Муртазин on 05.12.13.
//


#import "SBImageCell.h"
#import "SBImageManager.h"
#import "SBRecord.h"


@implementation SBImageCell {

}

- (void)fillByRecord:(SBRecord *)record {

    [super fillByRecord:record];

    self.mainLabel.text = @"";

    _mainImageView.image = nil;

    _mainImageView.hidden = YES;

    [_activityIndicatorView startAnimating];

    [[SBImageManager manager] showImage:[record value] inImageCell:self];
}

@end