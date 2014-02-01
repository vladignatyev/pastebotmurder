#import "SBMainViewController.h"
#import "SBImageCell.h"
#import <Dropbox/Dropbox.h>

#import "AppKeys.h"
#import "SBRecord.h"
#import "SBImageViewController.h"
#import "SBImageManager.h"
#import "SBLinkCell.h"
#import "SBPlainTextViewController.h"
#import "SBSettingsViewController.h"
#import "Mixpanel.h"

@implementation SBMainViewController


- (void)dealloc {

    [_store removeObserver:self];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setUpNavigationBar];

    [self setupTasks];

    //[self setUpAudio];
}

- (void)setUpNavigationBar {

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

    if (IS_iOS6) {

        CGRect frame = self.navigationController.navigationBar.frame;
        frame.origin.y = 20;
        self.navigationController.navigationBar.frame = frame;
    }
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [[Mixpanel sharedInstance] track:@"open main screen"];
}

- (void)setUpAudio {
// todo: not necessary for AppStore approval process. skipping sound setup.
//    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Buf1" ofType:@"aif"];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:soundPath], &_soundBuf1);
//
//    soundPath = [[NSBundle mainBundle] pathForResource:@"Buf2" ofType:@"aif"];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:soundPath], &_soundBuf2);
}

// user events

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self isEmpty]) {

        return;
    }

    SBRecord *record = [SBRecord recordByDBRecord:_records[[indexPath row]]];

    if ([record isLink]) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[record value]]];

        [[Mixpanel sharedInstance] track:@"open" properties:@{@"type" : @"link"}];

    } else if ([record isMail]) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", [record value]]]];

        [[Mixpanel sharedInstance] track:@"open" properties:@{@"type" : @"mail"}];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    DBRecord *dbRecord = _records[[indexPath row]];

    SBRecord *record = [SBRecord recordByDBRecord:dbRecord];

    if ([record isImage]) {

        [[SBImageManager manager] deleteImageByName:[record value]];
    }

    [record deleteRecord];

    [self logDeleteRecord:dbRecord];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.destinationViewController isKindOfClass:[SBSettingsViewController class]]) {

        SBSettingsViewController *plainTextViewController = (SBSettingsViewController *) segue.destinationViewController;

        plainTextViewController.store = self.store;

    } else {

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
}




// table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([self isEmpty]) {

        return 1;
    }

    return [_records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self isEmpty]) {

        return [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
    }

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

    if ([self isEmpty]) {

        return NO;
    }

    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = nil;

    if ([self isEmpty]) {

        cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];

    } else {

        SBRecord *record = [SBRecord recordByDBRecord:_records[[indexPath row]]];

        if ([record isImage]) {

            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];

        } else {

            cell = [tableView dequeueReusableCellWithIdentifier:@"BaseCell"];
        }
    }

    return cell.frame.size.height;
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

            if (!slf.isConnected) {

                slf.isConnected = YES;

                slf.timerForFirstUpdate = [NSTimer scheduledTimerWithTimeInterval:2
                                                                           target:slf
                                                                         selector:@selector(connectedFinishAndNotNewInserts)
                                                                         userInfo:nil
                                                                          repeats:NO];

            }

            if (slf.store.status & (DBDatastoreIncoming | DBDatastoreOutgoing)) {

                [slf.timerForFirstUpdate invalidate];

                [slf syncTasks];

            }
        }];


        self.records = [NSMutableArray arrayWithArray:[[self.store getTable:BUFS_TABLE] query:nil error:nil]];

        [self sortRecordsArray];

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

    BOOL isBeforeEmpty = [self isEmpty];

    NSMutableArray *deleted = [NSMutableArray array];
    for (int i = [_records count] - 1; i >= 0; i--) {
        DBRecord *record = _records[i];
        if ([record isDeleted]) {
            [deleted addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [_records removeObjectAtIndex:i];
        }
    }

    if ([deleted count] > 0) {

        if ([self isEmpty]) {

            isBeforeEmpty = YES;

            [self.tableView reloadData];

        } else {

            [self.tableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }


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

    if ([updates count] > 0) {

        [self.tableView reloadRowsAtIndexPaths:updates withRowAnimation:UITableViewRowAnimationAutomatic];
    }


    [_records addObjectsFromArray:changed];

    [self sortRecordsArray];

    NSMutableArray *inserts = [NSMutableArray array];

    for (DBRecord *record in changed) {

        int idx = [_records indexOfObject:record];

        [inserts addObject:[NSIndexPath indexPathForRow:idx inSection:0]];

        [self logInsertRecord:record];
    }

    if ([inserts count]) {

        if (isBeforeEmpty) {

            [self.tableView reloadData];

        } else {

            [self.tableView insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}




// system

- (void)sortRecordsArray {

    [_records sortUsingComparator:^(DBRecord *record1, DBRecord *record2) {

        return [record2[@"created"] compare:record1[@"created"]];
    }];
}

- (void)connectedFinishAndNotNewInserts {

    //[self checkFirstRunForWelcomPastes];
}

- (void)checkFirstRunForWelcomPastes {

    if (![[NSUserDefaults standardUserDefaults] boolForKey:FIRST_RUN_KEY]) {

        [self insertWelcomePastes];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_RUN_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)insertWelcomePastes {

    DBTable *table = [self.store getTable:BUFS_TABLE];

    [_records addObject:
            [table insert:@{
                    @"value" : @"test text",
                    @"type" : @"plain",
                    @"created" : [NSDate date]
            }]];

    [_records addObject:
            [table insert:@{
                    @"value" : @"ShotBufTeam@gmail.com",
                    @"type" : @"email",
                    @"created" : [NSDate date]
            }]];

    [_records addObject:
            [table insert:@{
                    @"value" : @"http://shotbuf.com/",
                    @"type" : @"www",
                    @"title" : @"English title please",
                    @"created" : [NSDate date]
            }]];

    //image

    NSString *name = @"welcomeScreen.png";

    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBPath *path = [[DBPath root] childPath:name];

    DBFile *file = [filesystem createFile:path error:nil];

    [file writeData:UIImagePNGRepresentation([UIImage imageNamed:@"WelcomeScreen.png"]) error:nil];

    [file close];

    [_records addObject:
            [table insert:@{
                    @"value" : name,
                    @"type" : @"image",
                    @"created" : [NSDate date]
            }]];


    [self sortRecordsArray];
}

//todo: sound needs improvement. not necessary for AppStore approval process
- (void)playRandomSoundBuf {

//    if (arc4random() % 2) {
//
//        AudioServicesPlaySystemSound(_soundBuf1);
//
//    } else {
//
//        AudioServicesPlaySystemSound(_soundBuf2);
//    }
}

- (void)logInsertRecord:(DBRecord *)record {

    SBRecord *_record = [SBRecord recordByDBRecord:record];

    [[Mixpanel sharedInstance] track:@"insert" properties:@{@"type" : [_record typeToString]}];
}

- (void)logDeleteRecord:(DBRecord *)record {

    SBRecord *_record = [SBRecord recordByDBRecord:record];

    [[Mixpanel sharedInstance] track:@"delete" properties:@{@"type" : [_record typeToString]}];
}

- (BOOL)isEmpty {

    return [_records count] == 0;
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
