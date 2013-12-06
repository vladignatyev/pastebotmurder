//
//  NSString+LinkDetection.m
//  DropBuf Desktop
//
//  Created by Vladimir Ignatev on 06.12.13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

#import "NSString+LinkDetection.h"

@implementation NSString (LinkDetection)

//static NSError *error;
//static NSRegularExpression *webUrlRegex = [NSRegularExpression regularExpressionWithPattern: @""
//                                                                                    options: NSRegularExpressionCaseInsensitive
//                                                                                      error: &error];

- (BOOL) isWebURL {
    return ([self hasPrefix:@"http://"]
                                   || [self hasPrefix:@"https://"]
                                   || [self hasPrefix:@"www."]);
}

- (BOOL) isSchemeLink {
    NSURL* url = [NSURL URLWithString:self];
    if ([self isWebURL]) return NO;
    if ([url.scheme isEqualToString:@"http://"] || [url.scheme isEqualToString:@"https://"]) return NO;
    return url.scheme != nil;
}

- (BOOL) isEmail {
    NSString *regExPattern = @"^(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])(\\s*)$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];

    return regExMatches != 0;
//    NSString *emailRegex =
//    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
//    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
//    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
//    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
//    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
//    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
//    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
////    NSError* error = NULL;
////    NSRegularExpression* e = [NSRegularExpression regularExpressionWithPattern: emailRegex
////                                                                       options: NSRegularExpressionCaseInsensitive
////                                                                         error: &error];
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
//    
//    return [emailTest evaluateWithObject:self];
}


@end
