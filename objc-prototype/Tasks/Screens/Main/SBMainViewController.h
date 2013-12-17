#import <UIKit/UIKit.h>

@class DBDatastore;
@class DBAccount;
@class DBAccountManager;

@interface SBMainViewController : UITableViewController

- (IBAction)didPressUnlink;

@property (nonatomic, retain) IBOutlet UIView *headerView;

@property(nonatomic, readonly) DBAccountManager *accountManager;
@property(nonatomic, readonly) DBAccount *account;
@property(nonatomic, strong) DBDatastore *store;
@property(nonatomic, strong) NSMutableArray *records;

@property (nonatomic, strong) NSString *imageNameForOpen;
@property (nonatomic, strong) NSString *textToOpen;


@end
