#import "AppDelegate.h"
#import "AppColours.h"
#import "AppFonts.h"
#import "../Controllers/Home/HomeViewController.h"
#import "../Controllers/Subscriptions/SubscriptionsViewController.h"
#import "../Controllers/History/HistoryViewController.h"
#import "../Controllers/Playlists/PlaylistsViewController.h"
#import "../Controllers/Downloads/DownloadsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.tabBarController = [[UITabBarController alloc] init];

    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    UINavigationController *homeNavViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    homeNavViewController.tabBarItem.title = @"Home";

    SubscriptionsViewController *subscriptionsViewController = [[SubscriptionsViewController alloc] init];
    UINavigationController *subscriptionsNavViewController = [[UINavigationController alloc] initWithRootViewController:subscriptionsViewController];
    subscriptionsNavViewController.tabBarItem.title = @"Subscriptions";

    HistoryViewController *historyViewController = [[HistoryViewController alloc] init];
    UINavigationController *historyNavViewController = [[UINavigationController alloc] initWithRootViewController:historyViewController];
    historyNavViewController.tabBarItem.title = @"History";

    PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc] init];
    UINavigationController *playlistsNavViewController = [[UINavigationController alloc] initWithRootViewController:playlistsViewController];
    playlistsNavViewController.tabBarItem.title = @"Playlists";

    DownloadsViewController *downloadsViewController = [[DownloadsViewController alloc] init];
    UINavigationController *downloadsNavViewController = [[UINavigationController alloc] initWithRootViewController:downloadsViewController];
    downloadsNavViewController.tabBarItem.title = @"Downloads";

    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeNavViewController, subscriptionsNavViewController, historyNavViewController, playlistsNavViewController, downloadsNavViewController, nil];

	UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navBarAppearance configureWithOpaqueBackground];
    navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [AppColours textColour]};
    navBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
    [UINavigationBar appearance].standardAppearance = navBarAppearance;

    UITabBarItemAppearance *tabBarItemAppearance = [[UITabBarItemAppearance alloc] init];
    tabBarItemAppearance.normal.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:14]};
    tabBarItemAppearance.selected.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:14]};
    tabBarItemAppearance.disabled.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:14]};
    tabBarItemAppearance.focused.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:14]};
    
    UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
    [tabBarAppearance configureWithOpaqueBackground];
    tabBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
    tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance;
    tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearance;
    tabBarAppearance.compactInlineLayoutAppearance = tabBarItemAppearance;
    [UITabBar appearance].standardAppearance = tabBarAppearance;
    
    if (@available(iOS 15.0, *)){
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;
        [UITabBar appearance].scrollEdgeAppearance = tabBarAppearance;
    }

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end