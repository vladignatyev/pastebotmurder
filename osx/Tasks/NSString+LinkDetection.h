//
//  NSString+LinkDetection.h
//  DropBuf Desktop
//
//  Created by Vladimir Ignatev on 06.12.13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LinkDetection)
- (BOOL) isWebURL;
- (BOOL) isSchemeLink;
- (BOOL) isEmail;
@end
