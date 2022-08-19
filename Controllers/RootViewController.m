// Main

#import "RootViewController.h"

// Nav Bar

#import "Search/SearchViewController.h"
#import "Settings/SettingsViewController.h"

// Tab Bar

#import "Home/HomeViewController.h"
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

	self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];
    
    UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = @"RebornTube";
	titleLabel.textColor = [AppColours textColour];
	titleLabel.numberOfLines = 1;
	titleLabel.adjustsFontSizeToFitWidth = true;
	titleLabel.adjustsFontForContentSizeCategory = false;
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];

    self.navigationItem.leftBarButtonItem = titleButton;

	UILabel *searchLabel = [[UILabel alloc] init];
	searchLabel.text = @"Search";
	searchLabel.textColor = [UIColor systemBlueColor];
	searchLabel.numberOfLines = 1;
	searchLabel.adjustsFontSizeToFitWidth = true;
	searchLabel.adjustsFontForContentSizeCategory = false;
    searchLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *searchLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(search:)];
	searchLabelTap.numberOfTapsRequired = 1;
	[searchLabel addGestureRecognizer:searchLabelTap];

    UILabel *settingsLabel = [[UILabel alloc] init];
	settingsLabel.text = @"Settings";
	settingsLabel.textColor = [UIColor systemBlueColor];
	settingsLabel.numberOfLines = 1;
	settingsLabel.adjustsFontSizeToFitWidth = true;
	settingsLabel.adjustsFontForContentSizeCategory = false;
    settingsLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *settingsLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settings:)];
	settingsLabelTap.numberOfTapsRequired = 1;
	[settingsLabel addGestureRecognizer:settingsLabelTap];

    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView:searchLabel];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsLabel];
    
    self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];

    self.tabBar = [[UITabBarController alloc] init];

    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    homeViewController.title = @"Home";
    UINavigationController *homeNavViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];

    HistoryViewController *historyViewController = [[HistoryViewController alloc] init];
    historyViewController.title = @"History";
    UINavigationController *historyNavViewController = [[UINavigationController alloc] initWithRootViewController:historyViewController];

    PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc] init];
    playlistsViewController.title = @"Playlists";
    UINavigationController *playlistsNavViewController = [[UINavigationController alloc] initWithRootViewController:playlistsViewController];

    self.tabBar.viewControllers = [NSArray arrayWithObjects:homeNavViewController, historyNavViewController, playlistsNavViewController, nil];

    [self.view addSubview:self.tabBar.view];
}

@end

@implementation RootViewController (Privates)

- (void)search:(UITapGestureRecognizer *)recognizer {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings:(UITapGestureRecognizer *)recognizer {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

@end