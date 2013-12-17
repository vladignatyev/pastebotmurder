//
// Created by Ринат Муртазин on 11.12.13.
//


#import <Foundation/Foundation.h>

@class SBRecord;


@interface SBBaseCell : UITableViewCell

+ (float)defaultHeight;

@property (nonatomic, strong) IBOutlet UILabel *mainLabel;

@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

- (void)fillByRecord:(SBRecord *)record;

@end