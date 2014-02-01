#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class DBDatastore;
@class DBAccount;
@class DBAccountManager;

static NSString *const FIRST_PASTE_KEY = @"FirstPaste";

static NSString *const SB_HELP_URL = @"http://shotbuf.com/help/";

@interface SBMainViewController : UITableViewController <UIAlertViewDelegate>

@property(nonatomic, readonly) DBAccount *account;
@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, strong) NSMutableArray *records;

@property BOOL isConnected;
@property (nonatomic, strong) NSTimer *timerForFirstUpdate;

//@property SystemSoundID soundBuf1;
//@property SystemSoundID soundBuf2;

@end
