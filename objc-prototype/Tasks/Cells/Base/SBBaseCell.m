//
// Created by Ринат Муртазин on 11.12.13.
//


#import "SBBaseCell.h"
#import "SBRecord.h"


@implementation SBBaseCell {

}

- (NSString *)relativeDateString: (NSDate*) date
{
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [now timeIntervalSinceDate:date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:date toDate:now options:0];
    
    NSString *relativeString;
    
    if (delta < 0) {
        relativeString = @"!n the future!";
        
    } else if (delta < 1 * MINUTE) {
        relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%d seconds ago",components.second];
        
    } else if (delta < 2 * MINUTE) {
        relativeString =  @"a minute ago";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%d minutes ago",components.minute];
        
    } else if (delta < 90 * MINUTE) {
        relativeString = @"an hour ago";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%d hours ago",components.hour];
        
    } else if (delta < 48 * HOUR) {
        relativeString = @"yesterday";
        
    } else if (delta < 30 * DAY) {
        relativeString = [NSString stringWithFormat:@"%d days ago",components.day];
        
    } else if (delta < 12 * MONTH) {
        relativeString = (components.month <= 1) ? @"one month ago" : [NSString stringWithFormat:@"%d months ago",components.month];
        
    } else {
        relativeString = (components.year <= 1) ? @"one year ago" : [NSString stringWithFormat:@"%d years ago",components.year];
        
    }
    
    return relativeString;
}

- (void)fillByRecord:(SBRecord *)record {

    _mainLabel.text = [record value];
    
    _dateLabel.text = [self relativeDateString:[record created]];

    if ([record isPlain]) {

        _iconImageView.image = [UIImage imageNamed:@"textIcon.png"];

    } else if ([record isLink]) {

        _iconImageView.image = [UIImage imageNamed:@"linkIcon.png"];

    } else if ([record isImage]) {

        _iconImageView.image = [UIImage imageNamed:@"imageIcon.png"];

    } else if ([record isMail]) {

        _iconImageView.image = [UIImage imageNamed:@"mailIcon.png"];

    } else {

        _iconImageView.image = nil;
    }
}

@end