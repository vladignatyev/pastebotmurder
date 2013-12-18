#import "SBMainViewController.h"
#import "SBImageCell.h"
#import <Dropbox/Dropbox.h>

#import "AppKeys.h"
#import "SBRecord.h"
#import "SBImageViewController.h"
#import "SBImageManager.h"
#import "SBLinkCell.h"
#import "SBPlainTextViewController.h"
#import "AppDelegate.h"

@implementation SBMainViewController


- (void)dealloc {

    [_store removeObserver:self];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setUpNavigationBar];

    [self setupTasks];
}

- (void)setUpNavigationBar {

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    if (IS_iOS6) {

        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarBG.png"]
                                                      forBarMetrics:UIBarMetricsDefault];

        [self.navigationController.navigationBar setShadowImage:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}



// user events

- (IBAction)didPressUnlink {

    [self unlinkAccount];

    [self openLoginScreen];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    SBRecord *record = [SBRecord recordByDBRecord:_records[[indexPath row]]];

    if ([record isLink]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[record value]]];
    } else if ([record isMail]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", [record value]]]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    SBRecord *record = [SBRecord recordByDBRecord:_records[[indexPath row]]];

    if ([record isImage]) {

        [[SBImageManager manager] deleteImageByName:[record value]];
    }

    [record deleteRecord];
    [_records removeObjectAtIndex:[indexPath row]];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    SBRecord *record = [SBRecord recordByDBRecord:_records[[path row]]];
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

    return [_records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SBRecord *record = [SBRecord recordByDBRecord:_records[[indexPath row]]];

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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {


    /*
     метод хреновый потому что каждая ячейка прогружается по два раза. не хорошо
    UITableViewCell *cell = [self tableView:tableView
                      cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
    */


    SBRecord *record = [SBRecord recordByDBRecord:_records[[indexPath row]]];

    if ([record isImage]) {

        return [SBImageCell defaultHeight];
    }

    return [SBBaseCell defaultHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    return [UIView new];
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

        self.records = [NSMutableArray arrayWithArray:[[self.store getTable:BUFS_TABLE] query:nil error:nil]];

        [_records sortUsingComparator:^(DBRecord *record1, DBRecord *record2) {

            return [record2[@"created"] compare:record1[@"created"]];
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
        DBRecord *record = _records[i];
        if ([record isDeleted]) {
            [deleted addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [_records removeObjectAtIndex:i];
        }
    }

    [self.tableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationAutomatic];

    NSMutableArray *changed = [NSMutableArray arrayWithArray:[changedDict[BUFS_TABLE] allObjects]];

    NSMutableArray *updates = [NSMutableArray array];

    for (int i = [changed count] - 1; i >= 0; i--) {
        DBRecord *record = changed[i];
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
    [_records sortUsingComparator:^(DBRecord *record1, DBRecord *record2) {

        return [record2[@"created"] compare:record1[@"created"]];
    }];

    NSMutableArray *inserts = [NSMutableArray array];

    for (DBRecord *record in changed) {
        int idx = [_records indexOfObject:record];
        [inserts addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationAutomatic];
}




// system

- (void)openLoginScreen {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)unlinkAccount {

    [[[DBAccountManager sharedManager] linkedAccount] unlink];

    _store = nil;
    _records = nil;
    [DBFilesystem setSharedFilesystem:nil];
}

- (DBAccount *)account {
    return [DBAccountManager sharedManager].linkedAccount;
}

- (DBDatastore *)store {
    if (!_store) {
        _store = [DBDatastore openDefaultStoreForAccount:self.account error:nil];
    }
    return _store;
}


@end
