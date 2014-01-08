#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class DBDatastore;
@class DBAccount;
@class DBAccountManager;

@interface SBMainViewController : UITableViewController

@property(nonatomic, readonly) DBAccount *account;
@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, strong) NSMutableArray *records;

@property BOOL isConnected;
@property (nonatomic, strong) NSTimer *timerForFirstUpdate;

//@property SystemSoundID soundBuf1;
//@property SystemSoundID soundBuf2;

@end
