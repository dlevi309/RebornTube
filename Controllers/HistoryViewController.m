#import "HistoryViewController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "HistoryVideosViewController.h"
#import "../Classes/YouTubeExtractor.h"

@interface HistoryViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    
    // Other
    NSMutableDictionary *historyIDDictionary;
}
- (void)keysSetup;
@end

@implementation HistoryViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [self keysSetup];

    UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = @"RebornTube";
	titleLabel.textColor = [UIColor whiteColor];
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

    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 50, self.view.bounds.size.width, 50)];
    tabBar.delegate = self;

    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"History" image:nil tag:1];
    [tabBarItems addObject:tabBarItem1];
    [tabBarItems addObject:tabBarItem2];

    tabBar.items = tabBarItems;
    tabBar.selectedItem = [tabBarItems objectAtIndex:1];
    [self.view addSubview:tabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    historyIDDictionary = [NSMutableDictionary new];

    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSMutableDictionary *historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - 50);
    
    int viewBounds = 0;
    int dateCount = 1;
    for (NSString *key in historyDictionary) {
        UIView *historyView = [[UIView alloc] init];
        historyView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        historyView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
        historyView.tag = dateCount;
        UITapGestureRecognizer *historyViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyTap:)];
        historyViewTap.numberOfTapsRequired = 1;
        [historyView addGestureRecognizer:historyViewTap];

        UILabel *historyDateLabel = [[UILabel alloc] init];
        historyDateLabel.frame = CGRectMake(10, 0, historyView.frame.size.width - 10, historyView.frame.size.height);
        historyDateLabel.text = key;
        historyDateLabel.textColor = [UIColor whiteColor];
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

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation HistoryViewController (Privates)

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    int selectedTag = tabBar.selectedItem.tag;
    if (selectedTag == 0) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];

        UINavigationController *homeViewControllerView = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        homeViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:homeViewControllerView animated:NO completion:nil];
    }
}

- (void)search:(UITapGestureRecognizer *)recognizer {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];

    UINavigationController *searchViewControllerView = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:searchViewControllerView animated:YES completion:nil];
}

- (void)settings:(UITapGestureRecognizer *)recognizer {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:settingsViewControllerView animated:YES completion:nil];
}

- (void)historyTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *historyViewID = [historyIDDictionary valueForKey:historyViewTag];

    HistoryVideosViewController *historyVideosViewController = [[HistoryVideosViewController alloc] init];
    historyVideosViewController.historyViewID = historyViewID;
    
    UINavigationController *historyVideosViewControllerView = [[UINavigationController alloc] initWithRootViewController:historyVideosViewController];
    historyVideosViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:historyVideosViewControllerView animated:NO completion:nil];
}

@end