//
//  DropboxSession.m
//  DropBuf Desktop
//
//  Created by Vladimir Ignatev on 05.12.13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

#import "DropboxSession.h"
#import <DropboxOSX/DropboxOSX.h>

@interface DropboxSession () 
@property (nonatomic, readonly) DBSession *session;
@property (nonatomic, retain) DBRestClient *restClient;
@end

@implementation DropboxSession

-(void) startWithAppKey: (NSString*) appKey andSecret:(NSString*) secret {
    _session = [[DBSession alloc] initWithAppKey:appKey
                                       appSecret:secret
                                            root:kDBRootAppFolder];
    [DBSession setSharedSession:self.session];

}


- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//        _restClient.delegate = self;
    }
    return _restClient;
}

-(void) uploadFileWith:(NSString *)name andPath: (NSString*) fullPath {
    NSString *destDir = @"/";
    [[self restClient] uploadFile:name
                           toPath:destDir
                    withParentRev:nil
                         fromPath:fullPath];
}


@end
