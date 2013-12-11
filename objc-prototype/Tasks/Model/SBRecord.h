//
// Created by Ринат Муртазин on 09.12.13.
//


#import <Foundation/Foundation.h>

@class DBRecord;


@interface SBRecord : NSObject

+ (id)recordByDBRecord:(DBRecord *)record;


@property (nonatomic, strong) DBRecord *record;

- (NSDate *)created;

- (NSString *)value;

- (NSString *)titleForLink;

- (BOOL)isLink;
- (BOOL)isMail;
- (BOOL)isPlain;
- (BOOL)isImage;
- (BOOL)isDeleted;

- (void)deleteRecord;

@end