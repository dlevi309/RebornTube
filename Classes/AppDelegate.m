#import "AppDelegate.h"
#import "../Controllers/RootViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] init]];
	self.window.rootViewController = self.rootViewController;
	[self.window makeKeyAndVisible];	
	return YES;
}

@end