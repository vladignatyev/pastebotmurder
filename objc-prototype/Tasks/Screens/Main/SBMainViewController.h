#import <UIKit/UIKit.h>

@class DBDatastore;
@class DBAccount;
@class DBAccountManager;

@interface SBMainViewController : UITableViewController

@property(nonatomic, readonly) DBAccount *account;
@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, strong) NSMutableArray *records;

@property BOOL isConnected;
@property (nonatomic, strong) NSTimer *timerForFirstUpdate;

@end
