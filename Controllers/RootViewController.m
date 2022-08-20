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
    homeViewController.title = @"Home";
    UINavigationController *homeNavViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];

    SubscriptionsViewController *subscriptionsViewController = [[SubscriptionsViewController alloc] init];
    subscriptionsViewController.title = @"Subscriptions";
    UINavigationController *subscriptionsNavViewController = [[UINavigationController alloc] initWithRootViewController:subscriptionsViewController];

    HistoryViewController *historyViewController = [[HistoryViewController alloc] init];
    historyViewController.title = @"History";
    UINavigationController *historyNavViewController = [[UINavigationController alloc] initWithRootViewController:historyViewController];

    PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc] init];
    playlistsViewController.title = @"Playlists";
    UINavigationController *playlistsNavViewController = [[UINavigationController alloc] initWithRootViewController:playlistsViewController];

    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeNavViewController, subscriptionsNavViewController, historyNavViewController, playlistsNavViewController, nil];

    [self.view addSubview:self.tabBarController.view];
}

@end