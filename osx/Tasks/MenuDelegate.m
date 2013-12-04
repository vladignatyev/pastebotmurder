//
//  MenuDelegate.m
//  Datastore Examples OSX
//
//  Created by Vladimir Ignatev on 04.12.13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

#import "MenuDelegate.h"

@implementation MenuDelegate
-(void)awakeFromNib{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:self.menu];
    [statusItem setTitle:@"DropBuf"];
    [statusItem setHighlightMode:YES];
}

@end
