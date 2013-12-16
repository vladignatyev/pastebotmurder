//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.

#import "AppDelegate.h"
#import "TaskCellView.h"

#import <Dropbox/Dropbox.h>
#import <CommonCrypto/CommonDigest.h>

#import "NSString+LinkDetection.h"

#define APP_KEY     @"84zxlqvsmm2py5y"
#define APP_SECRET  @"u5sva6uz22bvuyy"
#define BUFS_TABLE @"bufs_values"

@interface AppDelegate () <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>

@property(nonatomic, readonly) DBAccountManager *accountManager;
@property(nonatomic, readonly) DBAccount *account;

@property(nonatomic, retain) DBDatastore *store;
@property(nonatomic, retain) NSMutableArray *tasks;
@property(nonatomic, retain) NSTimer *clipboardTimer;

@property(nonatomic, retain) NSData *oldObject;
@property(nonatomic, assign) BOOL firstTime;
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

    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    _clipboardTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandler) userInfo:NULL repeats:YES];


}

- (void)timerHandler {

    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classes = [[NSArray alloc]
            initWithObjects:
                    [NSString class],
                    [NSImage class],
                    nil];
    NSDictionary *options = [NSDictionary dictionary];
    NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];

    if (copiedItems != nil && [self.account isLinked]) {
        NSObject *obj = [copiedItems objectAtIndex:0];

        if (![self isNewObject:obj]) {
            return;
        }

        if ([obj isKindOfClass:[NSImage class]]) {

            NSImage *img = (NSImage *) obj;

            NSBitmapImageRep *imgRep = [[img representations] objectAtIndex:0];
            NSData *data = [imgRep representationUsingType:NSPNGFileType properties:nil];

            NSString *dateString = [NSDateFormatter localizedStringFromDate:[[NSDate alloc] init]
                                                                  dateStyle:NSDateFormatterShortStyle
                                                                  timeStyle:NSDateFormatterMediumStyle];

            NSString *shotAt = @"Shot at ";
            NSString *tmpFileName = [[shotAt stringByAppendingString:dateString] stringByAppendingString:@".png"];

            NSString *tmpFilepath = @"/tmp/";
            [data writeToFile:[tmpFilepath stringByAppendingString:tmpFileName]
                   atomically:NO];

            DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
            if (!filesystem) {
                filesystem = [[DBFilesystem alloc] initWithAccount:self.account];
                [DBFilesystem setSharedFilesystem:filesystem];
            }
            DBError *error = nil;

            DBPath *path = [[DBPath root] childPath:tmpFileName];

            if (![filesystem fileInfoForPath:path error:&error]) { // see if path exists

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

                DBRecord *buf = [tasksTbl insert:@{@"value" : tmpFileName,
                        @"type" : @"image",
                        @"created" : [NSDate date]}];
                [_tasks addObject:buf];

            } else {
                NSLog(@"Error");
            }

        } else if ([obj isKindOfClass:[NSString class]]) {

            NSString *string = (NSString *) obj;
            
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *stringType = @"plain";
            if ([string isEmail]) {
                stringType = @"email";
            } else if ([string isSchemeLink]) {
                stringType = @"scheme";
            } else if ([string isWebURL]) {
                stringType = @"www";
            }

            DBTable *tasksTbl = [self.store getTable:BUFS_TABLE];
            __strong DBRecord *buf = [tasksTbl insert:@{@"value" : string,
                    @"type" : stringType,
                    @"created" : [NSDate date]}];
            [_tasks addObject:buf];


            if ([string isWebURL]) {

                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]
                                                   queue:[NSOperationQueue new]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                                           NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                                           if (responseText) {

                                               NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<title>([^<]+)</title>"
                                                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                                                        error:&error];

                                               NSTextCheckingResult *result = [regex firstMatchInString:responseText options:0 range:NSMakeRange(0, [responseText length])];

                                               if (result && [result numberOfRanges] > 1) {

                                                   NSString *title = [responseText substringWithRange:[result rangeAtIndex:1]];

                                                   buf[@"title"] = title;
                                               }
                                           }
                                       }];
            }
        }
    }
}

- (BOOL)isNewObject:(NSObject *)object {

    NSData *data;

    if ([object isKindOfClass:[NSImage class]]) {

        NSImage *img = (NSImage *) object;

        data = [img TIFFRepresentation];

    } else if ([object isKindOfClass:[NSString class]]) {

        NSString *string = (NSString *) object;

        data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }

    if ([_oldObject isEqualToData:data]) {

        return NO;

    } else {

        self.oldObject = data;

        return ([self isFirstTime] ? NO : YES );
    }
}

- (BOOL)isFirstTime {

    if (self.firstTime) {

        self.firstTime = NO;

        return YES;
    }

    return NO;
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

- (IBAction)didPressClearTable:(id)sender {

    // не нашел в доках более подходящего метода, чем удалять все записи по отдельности

    DBTable *bufsTbl = [self.store getTable:BUFS_TABLE];

    NSArray *records = [bufsTbl query:nil error:nil];

    for (DBRecord *record in records) {

        [record deleteRecord];
    }
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
        [self.store addObserver:self block:^{
            if (slf.store.status & (DBDatastoreIncoming | DBDatastoreOutgoing)) {
                [slf syncTasks];
            }
        }];
        _tasks = [NSMutableArray arrayWithArray:[[self.store getTable:@"tasks"] query:nil error:nil]];
        [_tasks sortUsingComparator:^(DBRecord *obj1, DBRecord *obj2) {
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
    [_tasks sortUsingComparator:^(DBRecord *obj1, DBRecord *obj2) {
        return [obj1[@"created"] compare:obj2[@"created"]];
    }];
    NSIndexSet *inserts = [_tasks indexesOfObjectsPassingTest:^BOOL(DBRecord *obj, NSUInteger idx, BOOL *stop) {
        return changed[obj.recordId] != nil;
    }];
    [self.tableView insertRowsAtIndexes:inserts withAnimation:NSTableViewAnimationEffectFade];
}

@end
