#import "HomeViewController.h"
#import "HistoryViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"

@interface HomeViewController ()
@end

@implementation HomeViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    
    self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];

    UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
    
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 50, self.view.bounds.size.width, 50)];
    tabBar.delegate = self;

    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"History" image:nil tag:1];
    [tabBarItems addObject:tabBarItem1];
    [tabBarItems addObject:tabBarItem2];

    tabBar.items = tabBarItems;
    tabBar.selectedItem = [tabBarItems objectAtIndex:0];
    [self.view addSubview:tabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 ||  [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
}

@end

@implementation HomeViewController (Privates)

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    int selectedTag = tabBar.selectedItem.tag;
    if (selectedTag == 1) {
        HistoryViewController *historyViewController = [[HistoryViewController alloc] init];

        UINavigationController *historyViewControllerView = [[UINavigationController alloc] initWithRootViewController:historyViewController];
        historyViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:historyViewControllerView animated:NO completion:nil];
    }
}

- (void)search {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];

    UINavigationController *searchViewControllerView = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:searchViewControllerView animated:YES completion:nil];
}

- (void)settings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:settingsViewControllerView animated:YES completion:nil];
}

@end