#import "AppDelegate.h"
#import "../Controllers/HomeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.homeViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
	self.window.rootViewController = self.homeViewController;
	[self.window makeKeyAndVisible];	
	return YES;
}

@end