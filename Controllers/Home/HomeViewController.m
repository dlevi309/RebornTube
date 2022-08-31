// Main

#import "HomeViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/YouTubeExtractor.h"

// Views

#import "../../Views/MainDisplayView.h"

// Interface

@interface HomeViewController ()
{
    // Keys
	UIWindow *boundsWindow;
	UIScrollView *scrollView;

    // Main Dictionary
    NSMutableDictionary *mainDictionary;
}
- (void)keysSetup;
- (void)navBarSetup;
- (void)mainDictionarySetup;
- (void)mainViewSetup;
@end

@implementation HomeViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];

	[self keysSetup];
	[self navBarSetup];
	[self mainDictionarySetup];
	[self mainViewSetup];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
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

- (void)mainDictionarySetup {
	mainDictionary = [NSMutableDictionary new];
	NSDictionary *youtubeBrowseRequest = [YouTubeExtractor youtubeBrowseRequest:@"ANDROID":@"16.20":@"FEtrending":nil];
    NSArray *trendingContents = youtubeBrowseRequest[@"contents"][@"singleColumnBrowseResultsRenderer"][@"tabs"][0][@"tabRenderer"][@"content"][@"sectionListRenderer"][@"contents"];
	for (int i = 0 ; i <= 50 ; i++) {
		@try {
			if (trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"headline"][@"runs"][0][@"text"]) {
				NSArray *videoArtworkArray = trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"thumbnail"][@"thumbnails"];
				NSString *videoArtwork = [NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]];
				NSString *videoTime = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"lengthText"][@"runs"][0][@"text"]];
				NSString *videoTitle = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"headline"][@"runs"][0][@"text"]];
				NSString *videoCount = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"shortViewCountText"][@"runs"][0][@"text"]];
				NSString *videoAuthor = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"shortBylineText"][@"runs"][0][@"text"]];
				NSString *videoID = [NSString stringWithFormat:@"%@", trendingContents[i][@"itemSectionRenderer"][@"contents"][0][@"videoWithContextRenderer"][@"navigationEndpoint"][@"watchEndpoint"][@"videoId"]];
				
				/* NSMutableArray *mainArray = [[NSMutableArray alloc] init];
				[mainArray addObject:videoArtwork];
				[mainArray addObject:videoTime];
				[mainArray addObject:videoTitle];
				[mainArray addObject:videoCount];
				[mainArray addObject:videoAuthor];
				[mainArray addObject:videoID];
				[mainDictionary setValue:mainArray forKey:[NSString stringWithFormat:@"%d", i]]; */

				NSMutableDictionary *mainInfoDictionary = [NSMutableDictionary new];
				[mainInfoDictionary setValue:videoArtwork forKey:@"artwork"];
				[mainInfoDictionary setValue:videoTime forKey:@"time"];
				[mainInfoDictionary setValue:videoTitle forKey:@"title"];
				[mainInfoDictionary setValue:videoCount forKey:@"count"];
				[mainInfoDictionary setValue:videoAuthor forKey:@"author"];
				[mainInfoDictionary setValue:videoID forKey:@"id"];

				[mainDictionary setValue:mainInfoDictionary forKey:[NSString stringWithFormat:@"%d", i]];
			}
		}
        @catch (NSException *exception) {
        }
	}
}

- (void)mainViewSetup {
	[scrollView removeFromSuperview];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);

	int viewBounds = 0;
	for (int i = 0 ; i <= 50 ; i++) {
		@try {
			MainDisplayView *mainDisplayView = [[MainDisplayView alloc] initWithFrame:CGRectMake(0, viewBounds, self.view.bounds.size.width, 100)];
			/* NSArray *info = [mainDictionary valueForKey:@"0"];
			mainDisplayView.image = info[0]; */
			[scrollView addSubview:mainDisplayView];
			viewBounds += 102;
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

// Orientation

- (void)orientationChanged:(NSNotification *)notification {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		[self mainViewSetup];
		break;

		case UIInterfaceOrientationLandscapeLeft:
		[self mainViewSetup];
		break;

		case UIInterfaceOrientationLandscapeRight:
		[self mainViewSetup];
		break;

		case UIInterfaceOrientationPortraitUpsideDown:
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			[self mainViewSetup];
		}
		break;

		case UIInterfaceOrientationUnknown:
		break;
	}
}

@end