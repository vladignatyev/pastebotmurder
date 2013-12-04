//
//  DropboxSession.h
//  DropBuf Desktop
//
//  Created by Vladimir Ignatev on 05.12.13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DropboxSession : NSObject
-(void) startWithAppKey: (NSString*) appKey andSecret:(NSString*) secret;
@end
