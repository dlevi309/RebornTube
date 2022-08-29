// Main

#import "RootViewController.h"

// Tab Bar

#import "Home/HomeViewController.h"
#import "Subscriptions/SubscriptionsViewController.h"
#import "History/HistoryViewController.h"
#import "Playlists/PlaylistsViewController.h"

// Classes

#import "../Classes/AppColours.h"

// Interface

@interface RootViewController ()
@end

@implementation RootViewController

- (void)loadView {
	[super loadView];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

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

    [self.view addSubview:self.tabBarController.view];
}

@end