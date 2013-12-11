//
// Created by Ринат Муртазин on 11.12.13.
//


#import "SBLinkCell.h"
#import "SBRecord.h"


@implementation SBLinkCell {

}

- (void)fillByRecord:(SBRecord *)record {

    [super fillByRecord:record];

    self.mainLabel.text = @"Title";

    _linkLabel.text = [record value];
}

@end