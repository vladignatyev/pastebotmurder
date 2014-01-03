//
// Created by Ринат Муртазин on 11.12.13.
//


#import "SBLinkCell.h"
#import "SBRecord.h"


@implementation SBLinkCell {

}

- (void)fillByRecord:(SBRecord *)record {

    [super fillByRecord:record];

    float linkLabelY;

    if(![[record titleForLink] isEqualToString:@""]) {

        linkLabelY = 38;

    } else {

        linkLabelY = 20;
    }

    CGRect frame = _linkLabel.frame;
    frame.origin.y = linkLabelY;
    _linkLabel.frame = frame;

    _linkLabel.text = [record value];
    self.mainLabel.text = [record titleForLink];
}

@end