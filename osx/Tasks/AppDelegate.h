//  Copyright (c) 2013 ShotBuf. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *welcomeWindow;
@property (weak) IBOutlet NSMenu *menu;

@property (weak) IBOutlet NSMenuItem *unlinkDropboxItem;
@property (weak) IBOutlet NSMenuItem *enableShotBufItem;

- (IBAction)didPressLinkUnlinkButton:(id)sender;


@end
