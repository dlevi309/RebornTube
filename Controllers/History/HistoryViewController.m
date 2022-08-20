// Main

#import "HistoryViewController.h"
#import "VideoHistoryViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Tab Bar

#import "../Home/HomeViewController.h"
#import "../Subscriptions/SubscriptionsViewController.h"
#import "../Playlists/PlaylistsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface HistoryViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    UIScrollView *scrollView;
    
    // Other
    NSMutableDictionary *historyIDDictionary;
}
- (void)keysSetup;
- (void)navBarSetup;
- (void)tabBarSetup;
@end

@implementation HistoryViewController

- (void)loadView {
	[super loadView];

    self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
	[self navBarSetup];
	[self tabBarSetup];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
    scrollView = [[UIScrollView alloc] init];
}

- (void)navBarSetup {
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
}

- (void)tabBarSetup {
	UITabBar *tabBar = [[UITabBar alloc] init];
    tabBar.frame = CGRectMake(0, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 50, self.view.bounds.size.width, 50);
    tabBar.delegate = self;

    UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
	UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"Subscriptions" image:nil tag:1];
    UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"History" image:nil tag:2];
    UITabBarItem *tabBarItem4 = [[UITabBarItem alloc] initWithTitle:@"Playlists" image:nil tag:3];
    
	tabBar.items = @[tabBarItem1, tabBarItem2, tabBarItem3, tabBarItem4];
    tabBar.selectedItem = [tabBar.items objectAtIndex:2];
    [self.view addSubview:tabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    historyIDDictionary = [NSMutableDictionary new];
    [scrollView removeFromSuperview];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSMutableDictionary *historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];
    NSArray *historyDictionarySorted = [[[historyDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] reverseObjectEnumerator];

    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - 50);
    
    int viewBounds = 0;
    int dateCount = 1;
    for (NSString *key in historyDictionarySorted) {
        UIView *historyView = [[UIView alloc] init];
        historyView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        historyView.backgroundColor = [AppColours viewBackgroundColour];
        historyView.tag = dateCount;
        UITapGestureRecognizer *historyViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyTap:)];
        historyViewTap.numberOfTapsRequired = 1;
        [historyView addGestureRecognizer:historyViewTap];

        UILabel *historyDateLabel = [[UILabel alloc] init];
        historyDateLabel.frame = CGRectMake(10, 0, historyView.frame.size.width - 10, historyView.frame.size.height);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:key];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        historyDateLabel.text = [dateFormatter stringFromDate:date];
        historyDateLabel.textColor = [AppColours textColour];
        historyDateLabel.numberOfLines = 1;
        historyDateLabel.adjustsFontSizeToFitWidth = true;
        historyDateLabel.adjustsFontForContentSizeCategory = false;
        [historyView addSubview:historyDateLabel];

        [historyIDDictionary setValue:key forKey:[NSString stringWithFormat:@"%d", dateCount]];
        viewBounds += 42;
        dateCount += 1;

        [scrollView addSubview:historyView];
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

@end

@implementation HistoryViewController (Privates)

// Nav Bar

- (void)search:(UITapGestureRecognizer *)recognizer {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings:(UITapGestureRecognizer *)recognizer {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

// Tab Bar

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    int selectedTag = tabBar.selectedItem.tag;
	if (selectedTag == 0) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];
		[self.navigationController pushViewController:homeViewController animated:NO];
    }
	if (selectedTag == 1) {
        SubscriptionsViewController *subscriptionsViewController = [[SubscriptionsViewController alloc] init];
		[self.navigationController pushViewController:subscriptionsViewController animated:NO];
    }
    if (selectedTag == 2) {
        HistoryViewController *historyViewController = [[HistoryViewController alloc] init];
		[self.navigationController pushViewController:historyViewController animated:NO];
    }
    if (selectedTag == 3) {
        PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc] init];
		[self.navigationController pushViewController:playlistsViewController animated:NO];
    }
}

// Other

- (void)historyTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *historyViewID = [historyIDDictionary valueForKey:historyViewTag];

    VideoHistoryViewController *historyVideosViewController = [[VideoHistoryViewController alloc] init];
    historyVideosViewController.historyViewID = historyViewID;

    [self.navigationController pushViewController:historyVideosViewController animated:YES];
}

@end