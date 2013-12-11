#import "SBMainViewController.h"
#import "SBImageCell.h"
#import <Dropbox/Dropbox.h>

#import "AppKeys.h"
#import "SBRecord.h"
#import "SBImageViewController.h"
#import "SBImageManager.h"
#import "SBLinkCell.h"
#import "SBPlainTextViewController.h"

@implementation SBMainViewController


- (void)dealloc {

    [_store removeObserver:self];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.tableView.rowHeight = 50.0f;

    [self.accountManager addObserver:self block:^(DBAccount *account) {

        [self setupTasks];
    }];

    [self setupTasks];
}


// user events

- (IBAction)didPressLink {
    [[DBAccountManager sharedManager] linkFromController:self];
}

- (IBAction)didPressUnlink {
    [[[DBAccountManager sharedManager] linkedAccount] unlink];
    self.store = nil;

    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    SBRecord *record = _records[[indexPath row]];

    if ([record isLink]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[record value]]];
    } else if ([record isMail]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", [record value]]]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    SBRecord *record = [_records objectAtIndex:[indexPath row]];
    [record deleteRecord];
    [_records removeObjectAtIndex:[indexPath row]];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    SBRecord *record = [_records objectAtIndex: path.row ];
    NSString *value = [record value];
    
    if ([segue.destinationViewController isKindOfClass:[SBImageViewController class]]) {
        SBImageViewController *imageViewController = (SBImageViewController *) segue.destinationViewController;

        imageViewController.imageName = value;
    } else if ([segue.destinationViewController isKindOfClass:[SBPlainTextViewController class]]) {
        SBPlainTextViewController *plainTextViewController = (SBPlainTextViewController *) segue.destinationViewController;

        plainTextViewController.textToPresent = value;
    }
}


// table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.account) {
        return 1;
    } else {
        return [_records count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (![DBAccountManager sharedManager].linkedAccount) {

        return [tableView dequeueReusableCellWithIdentifier:@"LoginCell"];

    } else if ([indexPath row] == [_records count]) {

        return [tableView dequeueReusableCellWithIdentifier:@"UnlinkCell"];

    } else {

        SBRecord *record = _records[[indexPath row]];

        if ([record isImage]) {

            SBImageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];

            [imageCell fillByRecord:record];

            return imageCell;

        } else if ([record isLink]) {

            SBLinkCell *linkCell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell"];

            [linkCell fillByRecord:record];

            return linkCell;

        } else {

            SBBaseCell *baseCell = [tableView dequeueReusableCellWithIdentifier:([record isMail] ? @"MailCell" : @"BaseCell")];

            [baseCell fillByRecord:record];

            return baseCell;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.account && [indexPath row] < [_records count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 24.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 85;
}

// model

- (void)setupTasks {

    if (self.account) {

        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:self.account];
        [DBFilesystem setSharedFilesystem:filesystem];

        __weak SBMainViewController *slf = self;

        [self.store addObserver:self block:^{
            if (slf.store.status & (DBDatastoreIncoming | DBDatastoreOutgoing)) {
                [slf syncTasks];
            }
        }];

        NSArray *tempRecords = [NSMutableArray arrayWithArray:[[self.store getTable:BUFS_TABLE] query:nil error:nil]];

        self.records = [NSMutableArray arrayWithCapacity:[tempRecords count]];

        for (DBRecord *record in tempRecords) {

            [_records addObject:[SBRecord recordByDBRecord:record]];
        }

        [_records sortUsingComparator:^(SBRecord *record1, SBRecord *record2) {

            return [[record2 created] compare:[record1 created]];
        }];

    } else {

        _store = nil;
        _records = nil;
        [DBFilesystem setSharedFilesystem:nil];
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

    NSMutableArray *deleted = [NSMutableArray array];
    for (int i = [_records count] - 1; i >= 0; i--) {
        SBRecord *record = _records[i];
        if ([record isDeleted]) {
            [deleted addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [_records removeObjectAtIndex:i];
        }
    }

    [self.tableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationAutomatic];

    NSArray *tempChanged = [NSMutableArray arrayWithArray:[changedDict[BUFS_TABLE] allObjects]];

    NSMutableArray *changed = [NSMutableArray arrayWithCapacity:0];

    for (DBRecord *record in tempChanged) {

        [changed addObject:[SBRecord recordByDBRecord:record]];
    }

    NSMutableArray *updates = [NSMutableArray array];

    for (int i = [changed count] - 1; i >= 0; i--) {
        SBRecord *record = changed[i];
        if ([record isDeleted]) {
            [changed removeObjectAtIndex:i];
        } else {
            NSUInteger idx = [_records indexOfObject:record];
            if (idx != NSNotFound) {
                [updates addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                [changed removeObjectAtIndex:i];
            }
        }
    }
    [self.tableView reloadRowsAtIndexPaths:updates withRowAnimation:UITableViewRowAnimationAutomatic];


    [_records addObjectsFromArray:changed];
    [_records sortUsingComparator:^(SBRecord *record1, SBRecord *record2) {

        return [[record2 created] compare:[record1 created]];
    }];

    NSMutableArray *inserts = [NSMutableArray array];
    for (SBRecord *record in changed) {
        int idx = [_records indexOfObject:record];
        [inserts addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationAutomatic];
}




// system

- (DBAccount *)account {
    return [DBAccountManager sharedManager].linkedAccount;
}

- (DBAccountManager *)accountManager {
    return [DBAccountManager sharedManager];
}

- (DBDatastore *)store {
    if (!_store) {
        _store = [DBDatastore openDefaultStoreForAccount:self.account error:nil];
    }
    return _store;
}


@end
