//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.

#import "AppDelegate.h"
#import "TaskCellView.h"

#import <Dropbox/Dropbox.h>
#import <CommonCrypto/CommonDigest.h>

#define APP_KEY     @"84zxlqvsmm2py5y"
#define APP_SECRET  @"u5sva6uz22bvuyy"
#define BUFS_TABLE @"bufs_values"

@interface AppDelegate () <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>

@property (nonatomic, readonly) DBAccountManager *accountManager;
@property (nonatomic, readonly) DBAccount *account;

@property (nonatomic, retain) DBDatastore *store;
@property (nonatomic, retain) NSMutableArray *tasks;
@property (nonatomic, retain) NSTimer *clipboardTimer;

@property (nonatomic, retain) NSString* toPut;
@property (nonatomic, assign) BOOL firstTime;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.firstTime = YES;
    DBAccountManager *mgr = [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
    [DBAccountManager setSharedManager:mgr];
    __weak AppDelegate *weakSelf = self;
    [self.accountManager addObserver:self block:^(DBAccount *account) {
        [weakSelf setupTasks];
    }];
    [self setupTasks];
    
    [NSApp setActivationPolicy: NSApplicationActivationPolicyAccessory];
    
    _clipboardTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandler) userInfo:NULL repeats:YES];
    

}

- (void) timerHandler {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classes = [[NSArray alloc]
                        initWithObjects:
                        [NSString class],
                        [NSImage class],
                        nil];
    NSDictionary *options = [NSDictionary dictionary];
    NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];

    if (copiedItems != nil && [self.account isLinked]) {
        
        //todo: добавить проверку что объекты не идентичны (чтобы не добавлять повторно)
        
        NSObject* obj = [copiedItems objectAtIndex:0];
        if ([obj isKindOfClass:[NSImage class]]) {
            NSImage *img = (NSImage*) obj;
            
            NSBitmapImageRep *imgRep = [[img representations] objectAtIndex: 0];
            NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
            
            unsigned char hash[16];
            CC_MD5([data bytes], [data length], hash);
            
            NSString *imageHash = [NSString stringWithFormat:
                                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                                   hash[0], hash[1], hash[2], hash[3],
                                   hash[4], hash[5], hash[6], hash[7],
                                   hash[8], hash[9], hash[10], hash[11],
                                   hash[12], hash[13], hash[14], hash[15]
                                   ];
            
            if ([imageHash isEqualToString:self.toPut]) {
                return;
            }
            
            self.toPut = imageHash;
            if (self.firstTime) {
                self.firstTime = NO;
                return;
            }
            
            NSString *dateString = [NSDateFormatter localizedStringFromDate: [[NSDate alloc] init]
                                                                  dateStyle: NSDateFormatterShortStyle
                                                                  timeStyle: NSDateFormatterFullStyle];

            NSString *shotAt = @"Shot at ";
            NSString *tmpFileName =[[shotAt stringByAppendingString:dateString] stringByAppendingString:@".png"];
            
            NSString *tmpFilepath = @"/tmp/";
            [data writeToFile: [tmpFilepath stringByAppendingString: tmpFileName]
                   atomically: NO];
            
            DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
            if (!filesystem) {
                filesystem = [[DBFilesystem alloc] initWithAccount:self.account];
                [DBFilesystem setSharedFilesystem:filesystem];
            }
            DBError *error = nil;

            DBPath *path = [[DBPath root] childPath:tmpFileName];
            if (![filesystem fileInfoForPath:path error:&error]) { // see if path exists
                
                NSLog(@"%@", path);
                // Report error if path look up failed for some other reason than NOT FOUND
                if ([error code] != DBErrorParamsNotFound) {
                    NSLog(@"Error");
                }
                
                // Create a new test file.
                DBFile *file = [[DBFilesystem sharedFilesystem] createFile:path error:&error];
                if (!file) {
                    NSLog(@"Error");
                }
                
                // Write to the new test file.
                if (![file writeData:data error:&error]) {
                    NSLog(@"Error");
                }
                
                [file close];
                
                DBTable *tasksTbl = [self.store getTable:BUFS_TABLE];
                
                DBRecord *buf = [tasksTbl insert:@{@"value": path,
                                                   @"type": @"image",
                                                   @"created": [NSDate date] } ];
                [_tasks addObject:buf];
                
            } else {
                NSLog(@"Error");
            }
            
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *) obj;
            
            if ([string isEqualToString:self.toPut]) {
                return;
            }

            self.toPut = string;
            
            DBTable *tasksTbl = [self.store getTable:BUFS_TABLE];
            DBRecord *buf = [tasksTbl insert:@{@"value": self.toPut,
                                               @"type": @"plain",
                                               @"created": [NSDate date] } ];
            [_tasks addObject:buf];
        }
    }
}


#pragma mark NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (!self.account) {
        return 1; // link account
    } else {
        return [_tasks count] + 2; // 2 extra cells for input task and unlink account
    }
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (![DBAccountManager sharedManager].linkedAccount) {
        return [tableView makeViewWithIdentifier:@"LinkCell" owner:self];
    } else if (row == [_tasks count]) {
        return [tableView makeViewWithIdentifier:@"InputTaskCell" owner:self];
    } else if (row == [_tasks count]+1) {
        return [tableView makeViewWithIdentifier:@"UnlinkCell" owner:self];
    } else {
        TaskCellView *taskCell = [tableView makeViewWithIdentifier:@"TaskCell" owner:self];
        DBRecord *task = _tasks[row];
        taskCell.checkbox.title = task[@"taskname"];
        taskCell.checkbox.state = [task[@"completed"] boolValue] ? NSOnState : NSOffState;
        return taskCell;
    }
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (self.account) {
        if (row == [_tasks count] + 1) {
            return 34.0;
        }
    } else {
        return 34.0;
    }
    return 17.0;
}

#pragma mark - target-actions

- (IBAction)didPressLink:(id)sender {
    [[DBAccountManager sharedManager] linkFromWindow:[self window] withCompletionBlock:nil];
}
- (IBAction)didPressUnlink:(id)sender {
    [[[DBAccountManager sharedManager] linkedAccount] unlink];
    self.store = nil;

    [self.tableView reloadData];
}

- (IBAction)didClickTaskCheckbox:(id)sender {
    NSUInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        DBRecord *task = _tasks[row];
        task[@"completed"] = [task[@"completed"] boolValue] ? @NO : @YES;
        [[self tableView] reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
}

- (IBAction)didPressDeleteTask:(id)sender {
    NSUInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        DBRecord *record = _tasks[row];
        [record deleteRecord];
        [_tasks removeObjectAtIndex:row];
        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
    }
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSTextField *)textField textShouldEndEditing:(NSText *)fieldEditor {
    if (self.account && [textField.stringValue length]) {
        DBTable *tasksTbl = [self.store getTable:@"tasks"];

        DBRecord *task = [tasksTbl insert:@{ @"taskname": textField.stringValue, @"completed": @NO, @"created": [NSDate date] } ];
        [_tasks addObject:task];
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[_tasks count] - 1] withAnimation:NSTableViewAnimationEffectFade];

    }
    textField.stringValue = @"";
    return YES;
}

#pragma mark - private methods

- (DBAccountManager *)accountManager {
    return [DBAccountManager sharedManager];
}

- (DBAccount *)account {
    return self.accountManager.linkedAccount;
}

- (DBDatastore *)store {
    if (!_store && self.account) {
        _store = [DBDatastore openDefaultStoreForAccount:self.account error:nil];
    }
    return _store;
}

- (void)setupTasks {
    if (self.account) {
        __weak AppDelegate *slf = self;
        [self.store addObserver:self block:^ {
            if (slf.store.status & (DBDatastoreIncoming | DBDatastoreOutgoing)) {
                [slf syncTasks];
            }
        }];
        _tasks = [NSMutableArray arrayWithArray:[[self.store getTable:@"tasks"] query:nil error:nil]];
        [_tasks sortUsingComparator: ^(DBRecord *obj1, DBRecord *obj2) {
            return [obj1[@"created"] compare:obj2[@"created"]];
        }];
    } else {
        _store = nil;
        _tasks = nil;
    }
    [self.tableView reloadData];
    [self syncTasks];
}

- (void)syncTasks {
    if (self.account) {
        NSDictionary *changed = [self.store sync:nil];
        [self update:changed];
    }
}

- (void)update:(NSDictionary *)changedDict {
    NSMutableDictionary *changed = [NSMutableDictionary dictionary]; // dictionary of recordId -> record
    for (DBRecord *changedTask in [changedDict[@"tasks"] allObjects]) {
        changed[changedTask.recordId] = changedTask;
    }

    // Remove deleted rows, update existing rows
    NSMutableIndexSet *deletes = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *updates = [[NSMutableIndexSet alloc] init];
    [_tasks enumerateObjectsUsingBlock:^(DBRecord *obj, NSUInteger idx, BOOL *stop) {
        if (changed[obj.recordId] != nil) {
            if (obj.deleted) {
                [deletes addIndex:idx];
            } else {
                [updates addIndex:idx];
            }
            [changed removeObjectForKey:obj.recordId]; // mark that we processed this update
        }
    }];
    [_tasks removeObjectsAtIndexes:deletes];
    [self.tableView removeRowsAtIndexes:deletes withAnimation:NSTableViewAnimationEffectFade];
    [self.tableView reloadDataForRowIndexes:updates columnIndexes:[NSIndexSet indexSetWithIndex:0]];

    // Add new rows (in sorted order assuming _tasks is already sorted)
    [_tasks addObjectsFromArray:[changed allValues]]; // anything not processed in changed are inserts
    [_tasks sortUsingComparator: ^(DBRecord *obj1, DBRecord *obj2) {
        return [obj1[@"created"] compare:obj2[@"created"]];
    }];
    NSIndexSet *inserts = [_tasks indexesOfObjectsPassingTest:^BOOL(DBRecord *obj, NSUInteger idx, BOOL *stop) {
        return changed[obj.recordId] != nil;
    }];
    [self.tableView insertRowsAtIndexes:inserts withAnimation:NSTableViewAnimationEffectFade];
}

@end
