#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class DBDatastore;
@class DBAccount;
@class DBAccountManager;

static NSString *const FIRST_RUN_KEY = @"FirstRun";

@interface SBMainViewController : UITableViewController

@property(nonatomic, readonly) DBAccount *account;
@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, strong) NSMutableArray *records;

@property BOOL isConnected;
@property (nonatomic, strong) NSTimer *timerForFirstUpdate;

//@property SystemSoundID soundBuf1;
//@property SystemSoundID soundBuf2;

@end
