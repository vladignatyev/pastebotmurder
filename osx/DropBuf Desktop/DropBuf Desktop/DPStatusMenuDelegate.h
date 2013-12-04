//
//  DPStatusMenuDelegate.h
//  DropBuf Desktop
//
//  Created by Vladimir Ignatev on 04.12.13.
//  Copyright (c) 2013 Владимир Игнатьев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPStatusMenuDelegate : NSObject{
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;   
}

@property (assign) IBOutlet NSWindow *window;

@end
