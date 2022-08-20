// Main

#import "HomeViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Tab Bar

#import "../Subscriptions/SubscriptionsViewController.h"
#import "../History/HistoryViewController.h"
#import "../Playlists/PlaylistsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppHistory.h"
#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"

// Interface

@interface HomeViewController ()
{
    // Keys
	UIWindow *boundsWindow;
	UIScrollView *scrollView;

    // Other
    NSMutableDictionary *homeIDDictionary;
}
- (void)keysSetup;
- (void)navBarSetup;
- (void)tabBarSetup;
@end

@implementation HomeViewController

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
    tabBar.selectedItem = [tabBar.items objectAtIndex:0];
    [self.view addSubview:tabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    homeIDDictionary = [NSMutableDictionary new];
	[scrollView removeFromSuperview];
    
    NSMutableDictionary *youtubeAndroidBrowseRequest = [YouTubeExtractor youtubeAndroidBrowseRequest:@"FEtrending":nil];
    NSArray *trendingContents = youtubeAndroidBrowseRequest[@"contents"][@"singleColumnBrowseResultsRenderer"][@"tabs"][0][@"tabRenderer"][@"content"][@"sectionListRenderer"][@"contents"];
	
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - 50);
	
	int viewBounds = 0;
	for (int i = 1 ; i <= 50 ; i++) {
		@try {
			if (trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"headline"][@"runs"][0][@"text"]) {
				UIView *homeView = [[UIView alloc] init];
				homeView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
				homeView.backgroundColor = [AppColours viewBackgroundColour];
				homeView.tag = i;
				UITapGestureRecognizer *homeViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeTap:)];
				homeViewTap.numberOfTapsRequired = 1;
				[homeView addGestureRecognizer:homeViewTap];

				UIImageView *videoImage = [[UIImageView alloc] init];
				videoImage.frame = CGRectMake(0, 0, 80, 80);
				NSArray *videoArtworkArray = trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"thumbnail"][@"thumbnails"];
				NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
				videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
				[homeView addSubview:videoImage];

				UILabel *videoTimeLabel = [[UILabel alloc] init];
				videoTimeLabel.frame = CGRectMake(40, 65, 40, 15);
				videoTimeLabel.text = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"lengthText"][@"runs"][0][@"text"]];
				videoTimeLabel.textAlignment = NSTextAlignmentCenter;
				videoTimeLabel.textColor = [UIColor whiteColor];
				videoTimeLabel.numberOfLines = 1;
				videoTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
				videoTimeLabel.layer.cornerRadius = 5;
				videoTimeLabel.clipsToBounds = YES;
				videoTimeLabel.adjustsFontSizeToFitWidth = true;
				videoTimeLabel.adjustsFontForContentSizeCategory = false;
				[homeView addSubview:videoTimeLabel];

				UILabel *videoTitleLabel = [[UILabel alloc] init];
				videoTitleLabel.frame = CGRectMake(85, 0, homeView.frame.size.width - 85, 80);
				videoTitleLabel.text = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"headline"][@"runs"][0][@"text"]];
				videoTitleLabel.textColor = [AppColours textColour];
				videoTitleLabel.numberOfLines = 2;
				videoTitleLabel.adjustsFontSizeToFitWidth = true;
				videoTitleLabel.adjustsFontForContentSizeCategory = false;
				[homeView addSubview:videoTitleLabel];

				UILabel *videoCountAndAuthorLabel = [[UILabel alloc] init];
				videoCountAndAuthorLabel.frame = CGRectMake(5, 80, homeView.frame.size.width - 5, 20);
				videoCountAndAuthorLabel.text = [NSString stringWithFormat:@"%@ - %@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"shortViewCountText"][@"runs"][0][@"text"], trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"shortBylineText"][@"runs"][0][@"text"]];
				videoCountAndAuthorLabel.textColor = [AppColours textColour];
				videoCountAndAuthorLabel.numberOfLines = 1;
				[videoCountAndAuthorLabel setFont:[UIFont systemFontOfSize:12]];
				videoCountAndAuthorLabel.adjustsFontSizeToFitWidth = true;
				videoCountAndAuthorLabel.adjustsFontForContentSizeCategory = false;
				[homeView addSubview:videoCountAndAuthorLabel];
				
				[homeIDDictionary setValue:[NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"navigationEndpoint"][@"watchEndpoint"][@"videoId"]] forKey:[NSString stringWithFormat:@"%d", i]];
				viewBounds += 102;

				[scrollView addSubview:homeView];
			}
		}
        @catch (NSException *exception) {
        }
	}

	scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

@end

@implementation HomeViewController (Privates)

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

- (void)homeTap:(UITapGestureRecognizer *)recognizer {
    NSString *homeViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *videoID = [homeIDDictionary valueForKey:homeViewTag];

    [AppHistory init:videoID];
    [YouTubeLoader init:videoID];
}

@end