//
// Created by Ринат Муртазин on 09.12.13.
//


#import <Dropbox/Dropbox.h>
#import "SBRecord.h"


@implementation SBRecord {

}

+ (id)recordByDBRecord:(DBRecord *)record {

    SBRecord *result = [self new];

    result.record = record;

    return result;
}

- (NSDate *)created {

    return _record[@"created"];
}

- (NSString *)value {

    return _record[@"value"];
}

- (NSString *)titleForLink {

    NSString *result = _record[@"title"];

    if(!result) {

        result = @"";
    }

    return result;
}

- (BOOL)isLink {

    return [_record[@"type"] isEqualToString:@"www"] || [_record[@"type"] isEqualToString:@"scheme"];
}

- (BOOL)isMail {

    return [_record[@"type"] isEqualToString:@"email"];
}

- (BOOL)isPlain {

    return [_record[@"type"] isEqualToString:@"plain"];
}

- (BOOL)isImage {

    return [_record[@"type"] isEqualToString:@"image"];
}

- (BOOL)isDeleted {

    return _record.deleted;
}

- (void)deleteRecord {

    [_record deleteRecord];
}

@end