//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.

#import "AppDelegate.h"
#import "TaskCellView.h"
#import <Dropbox/Dropbox.h>

#define APP_KEY     @"nvdl2oouv53cpe1"
#define APP_SECRET  @"eu2ejm7b41gavas"


@interface AppDelegate () <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>

@property (nonatomic, readonly) DBAccountManager *accountManager;
@property (nonatomic, readonly) DBAccount *account;
@property (nonatomic, retain) DBDatastore *store;
@property (nonatomic, retain) NSMutableArray *tasks;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    DBAccountManager *mgr = [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
    [DBAccountManager setSharedManager:mgr];
    __weak AppDelegate *weakSelf = self;
    [self.accountManager addObserver:self block:^(DBAccount *account) {
        [weakSelf setupTasks];
    }];
    [self setupTasks];
    
    [NSApp setActivationPolicy: NSApplicationActivationPolicyAccessory];
//
//    NSLog(@"Window: %@", self.window);
//    [self.window makeKeyAndOrderFront:self];
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
