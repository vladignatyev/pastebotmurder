#import "AppDelegate.h"
#import <Dropbox/Dropbox.h>
#import "AppKeys.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    DBAccountManager *mgr = [[DBAccountManager alloc] initWithAppKey: APP_KEY
                                                              secret: APP_SECRET];
    [DBAccountManager setSharedManager:mgr];


    UIViewController *first = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];

    if(mgr.linkedAccount) {

        first = [storyboard instantiateViewControllerWithIdentifier:@"main"];

    } else {

        first = [storyboard instantiateInitialViewController];
    }

    self.window.rootViewController = first;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];


    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    [[DBAccountManager sharedManager] handleOpenURL:url];

    return YES;
}

@end
