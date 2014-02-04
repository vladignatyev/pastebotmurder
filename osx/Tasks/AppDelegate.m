//  Copyright (c) 2013 ShotBuf. All rights reserved.

#import "AppDelegate.h"

#import <Dropbox/Dropbox.h>
#import <CommonCrypto/CommonDigest.h>

#import "NSString+LinkDetection.h"
#import "SBRecord.h"
#import "SBImageManager.h"
#import <HockeySDK/HockeySDK.h>

#define APP_KEY     @"84zxlqvsmm2py5y"
#define APP_SECRET  @"u5sva6uz22bvuyy"
#define BUFS_TABLE @"bufs_values"

@interface AppDelegate ()
{

   NSStatusItem *statusItem;
}

@property(nonatomic, readonly) DBAccountManager *accountManager;
@property(nonatomic, readonly) DBAccount *account;

@property(nonatomic, retain) DBDatastore *store;
@property(nonatomic, retain) NSTimer *clipboardTimer;

@property(nonatomic, retain) NSData *oldObject;

@property(nonatomic, assign) BOOL justStarted;
@property(nonatomic, assign) BOOL shotBufEnabled;

@end


@implementation AppDelegate

//todo: делегировать другому классу, инстанс которого создавать при старте прилаги

- (NSString*) getFileTmpName {
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[[NSDate alloc] init]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterMediumStyle];
    
    NSString *shotAt = @"Shot at ";
    return [[shotAt stringByAppendingString:dateString] stringByAppendingString:@".png"];
    
}

- (NSData*) getDataFromImage:(NSImage*)image {
    NSBitmapImageRep *imgRep = [[image representations] objectAtIndex:0];
    NSData *data = [imgRep representationUsingType:NSPNGFileType properties:nil];
    return data;
}

- (DBFilesystem*) fileSystem {
    DBFilesystem* filesystem = [DBFilesystem sharedFilesystem];
    if (!filesystem) {
        filesystem = [[DBFilesystem alloc] initWithAccount:self.account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    return filesystem;
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

    if (copiedItems != nil && [copiedItems count] > 0 && [self.account isLinked]) {
        NSObject *obj = [copiedItems objectAtIndex:0];

        if (![self isNewObject:obj]) {
            return;
        }

        if ([obj isKindOfClass:[NSImage class]]) {
            
            NSData *data = [self getDataFromImage:(NSImage *) obj];

            NSString *tmpFileName = [self getFileTmpName];
            
            
            
//            [data writeToFile:[@"/tmp/" stringByAppendingString:tmpFileName]
//                   atomically:NO];

            DBFilesystem *filesystem = [self fileSystem];
            DBPath *path = [[DBPath root] childPath:tmpFileName];

            DBError *error = nil;
//            if (![filesystem fileInfoForPath:path error:&error]) { // see if path exists
                // Report error if path look up failed for some other reason than NOT FOUND
//                if ([error code] != DBErrorParamsNotFound) {
//                    NSLog(@"Error if path look up failed for some other reason than NOT FOUND %@", error);
//                }
            
            // Create a new file.
            DBFile *file = [filesystem createFile:path error:&error];
            if (!file) {
                NSLog(@"Error while creating new test file %@", error);
            }
            
            // Write to the new test file.
            if (![file writeData:data error:&error]) {
                NSLog(@"Error while writing data into test file %@", error);
            }
            
            [file close];
            
            DBTable *tasksTbl = [self.store getTable:BUFS_TABLE];
            
            [tasksTbl insert:@{@"value" : tmpFileName,
                               @"type" : @"image",
                               @"created" : [NSDate date]}];

            error = nil;
            NSDictionary *dictionary = [self.store sync:&error]; //
            NSLog(@"dictionary %@", dictionary);
            if (error) {
                NSLog(@"Error while syncing %@", error);
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
                                                   
                                                   DBError *error = nil;
                                                   [self.store sync:&error];
                                                   if (error) {
                                                       NSLog(@"Error while syncing after title preloading%@", error);
                                                   }

                                               }
                                           }
                                       }];
            }
            
            DBError *error = nil;
            NSDictionary* dictionary =[self.store sync:&error];
            NSLog(@"dictionary %@", dictionary);
            if (error) {
                NSLog(@"Error while syncing %@", error);
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
    }
    
    self.oldObject = data;
    return ([self isFirstTime] ? NO : YES );
}

#pragma mark - target-actions

- (IBAction)enableDisableShotBufAction:(id)sender {
    if (self.shotBufEnabled) {
        [self disableShotBuf];
    } else {
        [self enableShotBuf];
    }
}

- (IBAction)didPressWelcomeConnectButton:(id)sender {
    [self linkAccount];
}

- (IBAction)exitShotBuf:(id)sender {
    [NSApp terminate:self];
}

- (IBAction)didPressClearData:(id)sender {
    return; // TODO: удалено по соглашению с Виталей до полноценной версии десктопной прилаги
    [self disableShotBuf];
    
    DBTable *bufsTbl = [self.store getTable:BUFS_TABLE];
    NSArray *records = [bufsTbl query:nil error:nil];
    
    for (DBRecord *record in records) {
        SBRecord* sbRecord = [SBRecord recordByDBRecord:record];
        if (sbRecord.isImage) {
            NSString* imagePath = sbRecord.value;
            SBImageManager* imageManager = [SBImageManager manager];
            [imageManager deleteImageByName:imagePath];
        }
        [sbRecord deleteRecord];
        // TODO: если тип картинка - удалить и файлы из директории приложения
    }
    
    [self enableShotBuf];

}

- (IBAction)didPressLinkUnlinkButton:(id)sender {
    if (self.account){
        [self unlinkAccount];
        [self presentWelcomeWindow];
    } else {
        [self linkAccount];
    }
}

#pragma mark - lifecycle

//void MyLog(NSString* formattedString)
//{
//    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:@"/tmp/shotbuflog.txt"];
//    [myHandle seekToEndOfFile];
//    [myHandle writeData:[formattedString dataUsingEncoding:NSUTF8StringEncoding]];
//}

- (void)checkAndSetupRunAtStartup {
    NSString* plistPath = [@"~/Library/LaunchAgents/com.shotbuf.ShotBuf.plist" stringByExpandingTildeInPath];
    bool plistExist = [[NSFileManager defaultManager] fileExistsAtPath:plistPath];
    if (plistExist) return;
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pathToSourcePlist = [bundle pathForResource:@"com.shotbuf.ShotBuf" ofType:@"plist"];
    NSFileManager *manager = [[NSFileManager alloc] init];
    [manager copyItemAtPath:pathToSourcePlist toPath:plistPath error:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [self setupHockey];
    
    [self checkAndSetupRunAtStartup];
    self.justStarted = YES;
    [self setupDroboxSharedManager];
    [self passWelcomeScenario];
}

- (void)setupHockey {
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"7c721693a4d55d95e14969a4d3015f9b" companyName:@"ShotBuf" delegate:nil];
    [[BITHockeyManager sharedHockeyManager] startManager];
}

- (void)setupDroboxSharedManager {
    DBAccountManager *mgr = [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
    [DBAccountManager setSharedManager:mgr];
}

- (void)passWelcomeScenario {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"welcomePassed"];
    
    if ([defaults boolForKey:@"welcomePassed"] || self.account) {
        [self setupShotbuf];
        return;
    }
    
    [defaults setBool:YES forKey:@"welcomePassed"];
    [self presentWelcomeWindow];
}

- (void)presentWelcomeWindow {
    [self.unlinkDropboxItem setEnabled:NO];
    [self.enableShotBufItem setEnabled:NO];
    [self.clearDataItem setEnabled:NO];
    
    [self.welcomeWindow setLevel:NSModalPanelWindowLevel];
    [self.welcomeWindow makeKeyAndOrderFront:self];
    
    // Make the window visible on all Spaces
    if([self.welcomeWindow respondsToSelector: @selector(setCollectionBehavior:)]) {
        [self.welcomeWindow setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
    }
    else if([self.welcomeWindow respondsToSelector: @selector(canBeVisibleOnAllSpaces)]) {
        [self.welcomeWindow canBeVisibleOnAllSpaces]; // AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER_BUT_DEPRECATED
    }
}

- (void)closeWelcomeWindow {
    [self.welcomeWindow close];
}

- (void)tearDownShotBuf {
    [self disableShotBuf];
    [self.enableShotBufItem setEnabled:NO];
    [self.unlinkDropboxItem setTitle:@"Link Dropbox"];
    [self.enableShotBufItem setEnabled:NO];
    [self.clearDataItem setEnabled:NO];
    [self.accountManager removeObserver:self];
    _store = nil;
}

- (void)setupShotbuf {
    if (!self.account) {
        [self tearDownShotBuf];
        return;
    }
    __weak AppDelegate* weakSelf = self;
    [self.accountManager addObserver:self block:^(DBAccount *account) {
        [weakSelf tearDownShotBuf]; // https://www.dropbox.com/developers/sync/docs/osx#DBAccountManager
        [self.accountManager removeObserver:self];
    }];
    
    [self.store addObserver:self block:^(){
    }];

    [self.unlinkDropboxItem setTitle:@"Unlink Dropbox"];
    [self closeWelcomeWindow];
    [self enableShotBuf];
}

- (BOOL)isFirstTime {
    if (self.justStarted) {
        self.justStarted = NO;
        return YES;
    }
    return NO;
}

- (void)enableShotBuf {
    [self.enableShotBufItem setTitle:@"Disable ShotBuf"];
    [self.enableShotBufItem setEnabled:YES];
    [self.clearDataItem setEnabled:YES];

    _clipboardTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                       target:self
                                                     selector:@selector(timerHandler)
                                                     userInfo:NULL
                                                      repeats:YES];
    [self setNormalStatusIcon];
    self.shotBufEnabled = YES;
    
    [[DBFilesystem sharedFilesystem] addObserver:self block:^(){
        DBError *error = nil;
        [self.store sync:&error];
        if (error) {
            NSLog(@"Error while syncing after title preloading%@", error);
        }

    }];
}

- (void)disableShotBuf {
    [self.enableShotBufItem setTitle:@"Enable ShotBuf"];
    [_clipboardTimer invalidate];
    [self setDisabledStatusIcon];
    self.shotBufEnabled = NO;
}

#pragma mark - account methods

- (void) linkAccount {
    if (!self.welcomeWindow.isVisible) {
        [self.welcomeWindow makeKeyAndOrderFront:self];
    }
    
    __weak AppDelegate *weakSelf = self;
    [[DBAccountManager sharedManager]
     linkFromWindow:self.welcomeWindow withCompletionBlock:^(DBAccount *account){
         [weakSelf setupShotbuf];
         [self.unlinkDropboxItem setEnabled:YES];
     }];
}

- (void) unlinkAccount {
    [[[DBAccountManager sharedManager] linkedAccount] unlink];
    [self tearDownShotBuf];
}

- (DBAccountManager *)accountManager {
    return [DBAccountManager sharedManager];
}

- (DBAccount *)account {
    return self.accountManager.linkedAccount;
}

- (DBDatastore *)store {
    NSError * error = nil;
    if (!_store && self.account) {
        _store = [DBDatastore openDefaultStoreForAccount:self.account error:&error];
        if (error) {
            NSLog(@"Datastore error %@", [error localizedDescription]);
        }
    }
    return _store;
}

#pragma mark - UI methods

- (void)setupStatusBarMenu {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:self.menu];
    [statusItem setHighlightMode:YES];
    
    [self setDisabledStatusIcon];
    [self setAlternativeStatusIcon];
}

- (void)setAlternativeStatusIcon {
    NSImage* statusIconHighlighted = [NSImage imageNamed:@"statusbaricon_invert"];
    [statusItem setAlternateImage:statusIconHighlighted];
}


- (void)setDisabledStatusIcon {
    NSImage* statusIcon = [NSImage imageNamed:@"statusbaricon_black"];
    [statusItem setImage:statusIcon];
}

- (void)setNormalStatusIcon {
    NSImage* statusIcon = [NSImage imageNamed:@"statusbaricon"];
    [statusItem setImage:statusIcon];
}

- (void) awakeFromNib {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [self setupStatusBarMenu];
}

@end
