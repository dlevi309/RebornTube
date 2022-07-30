#import "HomeViewController.h"
#import "HistoryViewController.h"
#import "PlaylistsViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "PlayerViewController.h"
#import "../Classes/YouTubeExtractor.h"

@interface HomeViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
    NSMutableDictionary *homeIDDictionary;
}
- (void)keysSetup;
- (void)loadRequests :(NSString *)videoID;
- (void)player :(NSString *)videoTitle :(NSString *)videoLength :(NSURL *)videoArtwork :(NSString *)videoViewCount :(NSString *)videoLikes :(NSString *)videoDislikes :(NSURL *)audioURL :(NSURL *)videoStream :(NSMutableDictionary *)sponsorBlockValues;
@end

@implementation HomeViewController

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
    // [tabBarItems addObject:tabBarItem3];

    tabBar.items = tabBarItems;
    tabBar.selectedItem = [tabBarItems objectAtIndex:0];
    [self.view addSubview:tabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    homeIDDictionary = [NSMutableDictionary new];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 ||  [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }

    NSMutableDictionary *youtubeiAndroidTrendingRequest = [YouTubeExtractor youtubeiAndroidTrendingRequest];
    NSArray *trendingContents = youtubeiAndroidTrendingRequest[@"contents"][@"singleColumnBrowseResultsRenderer"][@"tabs"][0][@"tabRenderer"][@"content"][@"sectionListRenderer"][@"contents"][0][@"itemSectionRenderer"][@"contents"];
	
	/* UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);
	
	int viewBounds = 0;
	for (int i = 1 ; i <= 50 ; i++) {
		@try {
			UIView *homeView = [[UIView alloc] init];
			homeView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 80);
			homeView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
			homeView.tag = i;
			UITapGestureRecognizer *homeViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeTap:)];
			homeViewTap.numberOfTapsRequired = 1;
			[homeView addGestureRecognizer:homeViewTap];

			UIImageView *videoImage = [[UIImageView alloc] init];
			videoImage.frame = CGRectMake(0, 0, 80, homeView.frame.size.height);
            NSArray *videoArtworkArray = trendingContents[i][@"videoWithContextRenderer"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
			videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
			[homeView addSubview:videoImage];

			UILabel *videoTitleLabel = [[UILabel alloc] init];
			videoTitleLabel.frame = CGRectMake(85, 0, homeView.frame.size.width - 85, homeView.frame.size.height);
			videoTitleLabel.text = trendingContents[i][@"videoWithContextRenderer"][@"headline"][@"runs"][0][@"text"];
			videoTitleLabel.textColor = [UIColor whiteColor];
			videoTitleLabel.numberOfLines = 2;
			videoTitleLabel.adjustsFontSizeToFitWidth = true;
			videoTitleLabel.adjustsFontForContentSizeCategory = false;
			[homeView addSubview:videoTitleLabel];
			
			[homeIDDictionary setValue:[NSString stringWithFormat:@"%@", trendingContents[i][@"videoWithContextRenderer"][@"navigationEndpoint"][@"watchEndpoint"][@"videoId"]] forKey:[NSString stringWithFormat:@"%d", i]];
			viewBounds += 82;

			[scrollView addSubview:homeView];
		}
        @catch (NSException *exception) {
        }
	}

	scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView]; */
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
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
    if (selectedTag == 2) {
        PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc] init];

        UINavigationController *playlistsViewControllerView = [[UINavigationController alloc] initWithRootViewController:playlistsViewController];
        playlistsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:playlistsViewControllerView animated:NO completion:nil];
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

- (void)homeTap:(UITapGestureRecognizer *)recognizer {
    NSString *homeViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *videoID = [homeIDDictionary valueForKey:homeViewTag];

    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];

    NSMutableDictionary *historyDictionary;
    if (![fm fileExistsAtPath:historyPlistFilePath]) {
        historyDictionary = [[NSMutableDictionary alloc] init];
    } else {
        historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];
    }

    NSMutableArray *historyArray;
    if ([historyDictionary objectForKey:date]) {
        historyArray = [historyDictionary objectForKey:date];
    } else {
        historyArray = [[NSMutableArray alloc] init];
    }
    
    [historyArray addObject:videoID];

    [historyDictionary setValue:historyArray forKey:date];

    [historyDictionary writeToFile:historyPlistFilePath atomically:YES];

    [self loadRequests:videoID];
}
    
- (void)loadRequests :(NSString *)videoID {
    NSMutableDictionary *sponsorBlockValues = [YouTubeExtractor sponsorBlockRequest:videoID];

	NSMutableDictionary *returnYouTubeDislikeRequest = [YouTubeExtractor returnYouTubeDislikeRequest:videoID];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *videoViewCount = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"viewCount"]];
    NSString *videoLikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"likes"]];
    NSString *videoDislikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"dislikes"]];

    NSMutableDictionary *youtubeiiOSPlayerRequest = [YouTubeExtractor youtubeiiOSPlayerRequest:videoID];
    NSURL *videoStream = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubeiiOSPlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];

    NSMutableDictionary *youtubeiAndroidPlayerRequest = [YouTubeExtractor youtubeiAndroidPlayerRequest:videoID];
    NSString *videoTitle = [NSString stringWithFormat:@"%@", youtubeiAndroidPlayerRequest[@"videoDetails"][@"title"]];
    NSString *videoLength = [NSString stringWithFormat:@"%@", youtubeiAndroidPlayerRequest[@"videoDetails"][@"lengthSeconds"]];
    NSArray *videoArtworkArray = youtubeiAndroidPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
    NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
    NSDictionary *innertubeAdaptiveFormats = youtubeiAndroidPlayerRequest[@"streamingData"][@"adaptiveFormats"];
    NSURL *audioHigh;
    NSURL *audioMedium;
    NSURL *audioLow;
    for (NSDictionary *format in innertubeAdaptiveFormats) {
        if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_HIGH"]) {
            if (audioHigh == nil) {
                audioHigh = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_MEDIUM"]) {
            if (audioMedium == nil) {
                audioMedium = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_LOW"]) {
            if (audioLow == nil) {
                audioLow = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        }
    }

    NSURL *audioURL;
    if (audioHigh != nil) {
        audioURL = audioHigh;
    } else if (audioMedium != nil) {
        audioURL = audioMedium;
    } else if (audioLow != nil) {
        audioURL = audioLow;
    }

    UIAlertController *alertQualitySelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (videoStream != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Stream" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self player:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:nil:videoStream:sponsorBlockValues];
        }]];
    }
    if (audioURL != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Audio Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self player:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:audioURL:nil:sponsorBlockValues];
        }]];
    }

    [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertQualitySelector setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertQualitySelector popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;

    [self presentViewController:alertQualitySelector animated:YES completion:nil];
}

- (void)player :(NSString *)videoTitle :(NSString *)videoLength :(NSURL *)videoArtwork :(NSString *)videoViewCount :(NSString *)videoLikes :(NSString *)videoDislikes :(NSURL *)audioURL :(NSURL *)videoStream :(NSMutableDictionary *)sponsorBlockValues {
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.videoTitle = videoTitle;
    playerViewController.videoLength = videoLength;
    playerViewController.videoArtwork = videoArtwork;
    playerViewController.videoViewCount = videoViewCount;
    playerViewController.videoLikes = videoLikes;
    playerViewController.videoDislikes = videoDislikes;
    playerViewController.audioURL = audioURL;
    playerViewController.videoStream = videoStream;
    playerViewController.sponsorBlockValues = sponsorBlockValues;

    UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
    playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:playerViewControllerView animated:YES completion:nil];
}

@end