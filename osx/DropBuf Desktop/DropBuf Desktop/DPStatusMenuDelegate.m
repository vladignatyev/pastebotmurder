//
//  DPStatusMenuDelegate.m
//  DropBuf Desktop
//
//  Created by Vladimir Ignatev on 04.12.13.
//  Copyright (c) 2013 Владимир Игнатьев. All rights reserved.
//

#import "DPStatusMenuDelegate.h"

@implementation DPStatusMenuDelegate

@synthesize window;

-(void)awakeFromNib{
     statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"DropBuf"];
    [statusItem setHighlightMode:YES];
}

@end
