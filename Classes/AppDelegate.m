#import "AppDelegate.h"
#import "AppColours.h"
#import "Reachability.h"
#import "../Controllers/RootViewController.h"
#import "../Controllers/NoInternetViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [AppColours textColour]};
        navBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
        [UINavigationBar appearance].standardAppearance = navBarAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;

		UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
		[tabBarAppearance configureWithOpaqueBackground];
        tabBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
		[UITabBar appearance].standardAppearance = tabBarAppearance;
        [UITabBar appearance].scrollEdgeAppearance = tabBarAppearance;
    } else {
		UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [AppColours textColour]};
        navBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
        [UINavigationBar appearance].standardAppearance = navBarAppearance;

		UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
		[tabBarAppearance configureWithOpaqueBackground];
        tabBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
		[UITabBar appearance].standardAppearance = tabBarAppearance;
	}
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus != NotReachable) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] init]];
        self.window.rootViewController = self.rootViewController;
        [self.window makeKeyAndVisible];
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[NoInternetViewController alloc] init]];
        self.window.rootViewController = self.rootViewController;
        [self.window makeKeyAndVisible];
    }
    return YES;
}

@end