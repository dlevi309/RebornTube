// Main

#import "HomeViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"
#import "../../Classes/AppColours.h"

// Interface

@interface HomeViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
    NSMutableDictionary *homeIDDictionary;
}
- (void)keysSetup;
@end

@implementation HomeViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
	// self.navigationItem.titleView = [[UIView alloc] init];
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

    [self keysSetup];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    homeIDDictionary = [NSMutableDictionary new];
    
    NSMutableDictionary *youtubeAndroidBrowseRequest = [YouTubeExtractor youtubeAndroidBrowseRequest:@"FEtrending":nil];
    NSArray *trendingContents = youtubeAndroidBrowseRequest[@"contents"][@"singleColumnBrowseResultsRenderer"][@"tabs"][0][@"tabRenderer"][@"content"][@"sectionListRenderer"][@"contents"];
	
	UIScrollView *scrollView = [[UIScrollView alloc] init];
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

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation HomeViewController (Privates)

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
    
    if (![historyArray containsObject:videoID]) {
		[historyArray addObject:videoID];
	}

    [historyDictionary setValue:historyArray forKey:date];

    [historyDictionary writeToFile:historyPlistFilePath atomically:YES];

    [YouTubeLoader init:videoID];
}

- (void)search:(UITapGestureRecognizer *)recognizer {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings:(UITapGestureRecognizer *)recognizer {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

@end