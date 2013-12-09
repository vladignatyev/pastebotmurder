#import <UIKit/UIKit.h>

@class DBDatastore;
@class DBAccount;
@class DBAccountManager;

@interface TasksController : UITableViewController

- (IBAction)didPressLink;
- (IBAction)didPressUnlink;

@property (nonatomic, retain) IBOutlet UIView *headerView;

@property(nonatomic, readonly) DBAccountManager *accountManager;
@property(nonatomic, readonly) DBAccount *account;
@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, strong) NSMutableArray *records;

@property (nonatomic, strong) NSString *imageNameForOpen;

@end
