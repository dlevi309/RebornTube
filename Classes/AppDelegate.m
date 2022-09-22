#import "AppDelegate.h"
#import "AppColours.h"
#import "../Controllers/RootViewController.h"

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
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[RootViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end