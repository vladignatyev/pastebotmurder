#import "TasksController.h"
#import "TaskCell.h"
#import "ImageCell.h"
#import <Dropbox/Dropbox.h>

#import "AppKeys.h"
#import "SBRecord.h"

@interface TasksController () <UITableViewDataSource>

@property(nonatomic, readonly) DBAccountManager *accountManager;
@property(nonatomic, readonly) DBAccount *account;
@property(nonatomic, retain) DBDatastore *store;
@property(nonatomic, retain) NSMutableArray *records;

@end

@implementation TasksController


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

    } else if ([record isImage]) {

        UIViewController *newVC = [[UIViewController alloc] init];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 480)];

        imageView.contentMode = UIViewContentModeScaleAspectFit;

        [self showImage:[record value] inImageView:imageView];

        newVC.view.backgroundColor = [UIColor whiteColor];
        [newVC.view addSubview:imageView];

        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 100, 20)];

        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];

        [newVC.view addSubview:closeButton];

        [self presentModalViewController:newVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    SBRecord *record = [_records objectAtIndex:[indexPath row]];
    [record deleteRecord];
    [_records removeObjectAtIndex:[indexPath row]];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

        return [tableView dequeueReusableCellWithIdentifier:@"LinkCell"];

    } else if ([indexPath row] == [_records count]) {

        return [tableView dequeueReusableCellWithIdentifier:@"UnlinkCell"];

    } else {

        SBRecord *record = _records[[indexPath row]];

        if ([record isImage]) {

            ImageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];

            imageCell.taskLabel.text = @"image";

            imageCell.imageView2.image = nil;

            [imageCell.activityIndicatorView startAnimating];

            [self performSelectorInBackground:@selector(functionWrapperShowImageInImageView:) withObject:@[[record value], imageCell.imageView2]];

            return imageCell;

        } else {

            TaskCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];

            textCell.taskLabel.text = [record value];

            return textCell;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.account && [indexPath row] < [_records count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0f;
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


// model

- (void)setupTasks {

    if (self.account) {

        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:self.account];
        [DBFilesystem setSharedFilesystem:filesystem];

        __weak TasksController *slf = self;

        [self.store addObserver:self block:^{
            if (slf.store.status & (DBDatastoreIncoming | DBDatastoreOutgoing)) {
                [slf syncTasks];
            }
        }];

        NSArray *tempRecords = [NSMutableArray arrayWithArray:[[self.store getTable:BUFS_TABLE] query:nil error:nil]];

        self.records = [NSMutableArray arrayWithCapacity:[tempRecords count]];

        for(DBRecord *record in tempRecords) {

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

    for(DBRecord *record in tempChanged) {

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

- (void)showImage:(NSString *)imageName inImageView:(UIImageView *)imageView {

    DBPath *existingPath = [[DBPath root] childPath:imageName];

    DBError *error = nil;

    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:&error];

    if (error) {

        if ([error code] == DBErrorParamsNotFound) {

            [file close];

            [NSThread sleepForTimeInterval:1];

            [self performSelector:@selector(functionWrapperShowImageInImageView:) withObject:@[imageName, imageView]];
        }

    } else {

        UIImage *image = [UIImage imageWithData:[file readData:nil]];

        while (image == nil) {

            [file close];

            [NSThread sleepForTimeInterval:0.5];

            file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];

            image = [UIImage imageWithData:[file readData:nil]];
        }

        [file close];

        [self performSelectorOnMainThread:@selector(setImageInImageView:)
                               withObject:@[image, imageView]
                            waitUntilDone:NO];
    }
}

- (void)functionWrapperShowImageInImageView:(NSArray *)arguments {

    [self showImage:[arguments firstObject] inImageView:[arguments lastObject]];
}

- (void)setImageInImageView:(NSArray *)arguments {

    UIImage *image = [arguments firstObject];

    UIImageView *imageView = [arguments lastObject];

    imageView.image = image;
}


@end
