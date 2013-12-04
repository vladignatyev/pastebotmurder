//
//  MenuDelegate.h
//  Datastore Examples OSX
//
//  Created by Vladimir Ignatev on 04.12.13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuDelegate : NSObject
{
   NSStatusItem *statusItem;
}

@property (weak) IBOutlet NSMenu *menu;


@end
