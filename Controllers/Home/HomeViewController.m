// Main

#import "HomeViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppHistory.h"
#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"

// Other

#import "../Playlists/AddToPlaylistsViewController.h"

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
@end

@implementation HomeViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];

	[self keysSetup];
	[self navBarSetup];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
	scrollView = [[UIScrollView alloc] init];
}

- (void)navBarSetup {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = @"RebornTube";
	titleLabel.textColor = [AppColours textColour];
	titleLabel.numberOfLines = 1;
	titleLabel.adjustsFontSizeToFitWidth = YES;
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];

    self.navigationItem.leftBarButtonItem = titleButton;

	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    
    self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    homeIDDictionary = [NSMutableDictionary new];
	[scrollView removeFromSuperview];
    
    NSMutableDictionary *youtubeBrowseRequest = [YouTubeExtractor youtubeBrowseRequest:@"ANDROID":@"16.20":@"FEtrending":nil];
    NSArray *trendingContents = youtubeBrowseRequest[@"contents"][@"singleColumnBrowseResultsRenderer"][@"tabs"][0][@"tabRenderer"][@"content"][@"sectionListRenderer"][@"contents"];
	
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);
	
	int viewBounds = 0;
	for (int i = 1 ; i <= 50 ; i++) {
		@try {
			if (trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"headline"][@"runs"][0][@"text"]) {
				UIView *homeView = [[UIView alloc] init];
				homeView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
				homeView.backgroundColor = [AppColours viewBackgroundColour];
				homeView.tag = i;
				homeView.userInteractionEnabled = YES;
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
				videoTimeLabel.adjustsFontSizeToFitWidth = YES;
				[homeView addSubview:videoTimeLabel];

				UILabel *videoTitleLabel = [[UILabel alloc] init];
				videoTitleLabel.frame = CGRectMake(85, 0, homeView.frame.size.width - 85, 80);
				videoTitleLabel.text = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"headline"][@"runs"][0][@"text"]];
				videoTitleLabel.textColor = [AppColours textColour];
				videoTitleLabel.numberOfLines = 2;
				videoTitleLabel.adjustsFontSizeToFitWidth = YES;
				[homeView addSubview:videoTitleLabel];

				UILabel *videoCountAndAuthorLabel = [[UILabel alloc] init];
				videoCountAndAuthorLabel.frame = CGRectMake(5, 80, homeView.frame.size.width - 45, 20);
				videoCountAndAuthorLabel.text = [NSString stringWithFormat:@"%@ - %@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"shortViewCountText"][@"runs"][0][@"text"], trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"shortBylineText"][@"runs"][0][@"text"]];
				videoCountAndAuthorLabel.textColor = [AppColours textColour];
				videoCountAndAuthorLabel.numberOfLines = 1;
				[videoCountAndAuthorLabel setFont:[UIFont systemFontOfSize:12]];
				videoCountAndAuthorLabel.adjustsFontSizeToFitWidth = YES;
				[homeView addSubview:videoCountAndAuthorLabel];

				UILabel *videoActionLabel = [[UILabel alloc] init];
				videoActionLabel.frame = CGRectMake(homeView.frame.size.width - 30, 80, 20, 20);
				videoActionLabel.tag = i;
				videoActionLabel.text = @"•••";
				videoActionLabel.textAlignment = NSTextAlignmentCenter;
				videoActionLabel.textColor = [AppColours textColour];
				videoActionLabel.numberOfLines = 1;
				[videoActionLabel setFont:[UIFont systemFontOfSize:12]];
				videoActionLabel.adjustsFontSizeToFitWidth = YES;
				videoActionLabel.userInteractionEnabled = YES;
				UITapGestureRecognizer *videoActionLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeActionTap:)];
				videoActionLabelTap.numberOfTapsRequired = 1;
				[videoActionLabel addGestureRecognizer:videoActionLabelTap];
				[homeView addSubview:videoActionLabel];
				
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

- (void)search {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

// Other

- (void)homeTap:(UITapGestureRecognizer *)recognizer {
    NSString *homeViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *videoID = [homeIDDictionary valueForKey:homeViewTag];

    [AppHistory init:videoID];
    [YouTubeLoader init:videoID];
}

- (void)homeActionTap:(UITapGestureRecognizer *)recognizer {
    NSString *homeViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *videoID = [homeIDDictionary valueForKey:homeViewTag];

    UIAlertController *alertSelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoID]];
	
		UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
		[self presentViewController:shareSheet animated:YES completion:nil];
    }]];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		AddToPlaylistsViewController *addToPlaylistsViewController = [[AddToPlaylistsViewController alloc] init];
		addToPlaylistsViewController.videoID = videoID;

		[self presentViewController:addToPlaylistsViewController animated:YES completion:nil];
    }]];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertSelector setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertSelector popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;
    popPresenter.permittedArrowDirections = 0;

    [self presentViewController:alertSelector animated:YES completion:nil];
}

@end