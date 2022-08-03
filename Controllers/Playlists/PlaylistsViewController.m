// Main

#import "PlaylistsViewController.h"
#import "CreatePlaylistsViewController.h"
#import "VideoPlaylistsViewController.h"

// Nav Bar

#import "../SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Tab Bar

#import "../HomeViewController.h"
#import "../History/HistoryViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface PlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
    NSMutableDictionary *playlistsIDDictionary;
}
- (void)keysSetup;
@end

@implementation PlaylistsViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];
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

    UITabBar *tabBar = [[UITabBar alloc] init];
    tabBar.frame = CGRectMake(0, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 50, self.view.bounds.size.width, 50);
    tabBar.barStyle = UIBarStyleBlack;
    tabBar.delegate = self;

    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"History" image:nil tag:1];
    UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"Playlists" image:nil tag:2];
    [tabBarItems addObject:tabBarItem1];
    [tabBarItems addObject:tabBarItem2];
    [tabBarItems addObject:tabBarItem3];

    tabBar.items = tabBarItems;
    tabBar.selectedItem = [tabBarItems objectAtIndex:2];
    [self.view addSubview:tabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *createPlaylistsLabel = [[UILabel alloc] init];
    createPlaylistsLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 40);
    createPlaylistsLabel.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
    createPlaylistsLabel.text = @"Create Playlist";
    createPlaylistsLabel.textColor = [UIColor whiteColor];
    createPlaylistsLabel.numberOfLines = 1;
    createPlaylistsLabel.adjustsFontSizeToFitWidth = true;
    createPlaylistsLabel.adjustsFontForContentSizeCategory = false;
    createPlaylistsLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *createPlaylistsLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createPlaylistsTap:)];
    createPlaylistsLabelTap.numberOfTapsRequired = 1;
    [createPlaylistsLabel addGestureRecognizer:createPlaylistsLabelTap];

    [self.view addSubview:createPlaylistsLabel];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSMutableDictionary *playlistsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + createPlaylistsLabel.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - createPlaylistsLabel.frame.size.height - 50);
    
    int viewBounds = 0;
    int nameCount = 1;
    for (NSString *key in playlistsDictionary) {
        UIView *playlistsView = [[UIView alloc] init];
        playlistsView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        playlistsView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
        playlistsView.tag = nameCount;
        UITapGestureRecognizer *playlistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsTap:)];
        playlistsViewTap.numberOfTapsRequired = 1;
        [playlistsView addGestureRecognizer:playlistsViewTap];

        UILabel *playlistsNameLabel = [[UILabel alloc] init];
        playlistsNameLabel.frame = CGRectMake(10, 0, playlistsView.frame.size.width - 10, playlistsView.frame.size.height);
        playlistsNameLabel.text = key;
        playlistsNameLabel.textColor = [UIColor whiteColor];
        playlistsNameLabel.numberOfLines = 1;
        playlistsNameLabel.adjustsFontSizeToFitWidth = true;
        playlistsNameLabel.adjustsFontForContentSizeCategory = false;
        [playlistsView addSubview:playlistsNameLabel];

        [playlistsIDDictionary setValue:key forKey:[NSString stringWithFormat:@"%d", nameCount]];
        viewBounds += 42;
        nameCount += 1;

        [scrollView addSubview:playlistsView];
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation PlaylistsViewController (Privates)

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    int selectedTag = tabBar.selectedItem.tag;
    if (selectedTag == 0) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];

        UINavigationController *homeViewControllerView = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        homeViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:homeViewControllerView animated:NO completion:nil];
    }
    if (selectedTag == 1) {
        HistoryViewController *historyViewController = [[HistoryViewController alloc] init];

        UINavigationController *historyViewControllerView = [[UINavigationController alloc] initWithRootViewController:historyViewController];
        historyViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:historyViewControllerView animated:NO completion:nil];
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

- (void)createPlaylistsTap:(UITapGestureRecognizer *)recognizer {
    CreatePlaylistsViewController *createPlaylistsViewController = [[CreatePlaylistsViewController alloc] init];

    [self presentViewController:createPlaylistsViewController animated:YES completion:nil];
}

- (void)playlistsTap:(UITapGestureRecognizer *)recognizer {
    NSString *playlistsViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *playlistsViewID = [playlistsIDDictionary valueForKey:playlistsViewTag];

    VideoPlaylistsViewController *playlistsVideosViewController = [[VideoPlaylistsViewController alloc] init];
    playlistsVideosViewController.playlistsViewID = playlistsViewID;
    
    UINavigationController *playlistsVideosViewControllerView = [[UINavigationController alloc] initWithRootViewController:playlistsVideosViewController];
    playlistsVideosViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:playlistsVideosViewControllerView animated:NO completion:nil];
}

@end