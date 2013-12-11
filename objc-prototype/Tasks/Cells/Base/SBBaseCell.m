//
// Created by Ринат Муртазин on 11.12.13.
//


#import "SBBaseCell.h"
#import "SBRecord.h"


@implementation SBBaseCell {

}

- (void)fillByRecord:(SBRecord *)record {

    _mainLabel.text = [record value];

    if ([record isPlain]) {

        _iconImageView.image = [UIImage imageNamed:@"textIcon.png"];

    } else if ([record isLink]) {

        _iconImageView.image = [UIImage imageNamed:@"linkIcon.png"];

    } else if ([record isImage]) {

        _iconImageView.image = [UIImage imageNamed:@"imageIcon.png"];

    } else if ([record isMail]) {

        _iconImageView.image = [UIImage imageNamed:@"textIcon.png"];

    } else {

        _iconImageView.image = nil;
    }
}

@end