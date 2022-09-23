// Main

#import "SearchViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppHistory.h"
#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"

// Views

#import "../../Views/MainDisplayView.h"
#import "../../Views/MainPopupView.h"

// Interface

@interface SearchViewController ()
{
	// Keys
    UIWindow *boundsWindow;
	UIScrollView *scrollView;

	// Main Array
    NSMutableArray *mainArray;

	// Other
	UITextField *searchTextField;
}
- (void)keysSetup;
- (void)navBarSetup;
- (void)mainArraySetup;
- (void)mainViewSetup;
@end

@implementation SearchViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
	[self navBarSetup];
}

- (void)keysSetup {
    boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
	scrollView = [[UIScrollView alloc] init];
}

- (void)navBarSetup {
	searchTextField = [[UITextField alloc] init];
	searchTextField.placeholder = @"Search Here";
	searchTextField.translatesAutoresizingMaskIntoConstraints = NO;
	[searchTextField addTarget:self action:@selector(searchRequest) forControlEvents:UIControlEventEditingDidEndOnExit];
	self.navigationItem.titleView = searchTextField;
}

- (void)mainArraySetup {
	mainArray = [NSMutableArray new];
	NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"ANDROID":@"16.20":[searchTextField text]];
	NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
	if ([playabilityStatus isEqual:@"ERROR"]) {
		NSDictionary *youtubeSearchRequest = [YouTubeExtractor youtubeSearchRequest:@"WEB":@"2.20210401.08.00":[searchTextField text]];
		NSArray *searchContents = youtubeSearchRequest[@"contents"][@"twoColumnSearchResultsRenderer"][@"primaryContents"][@"sectionListRenderer"][@"contents"][0][@"itemSectionRenderer"][@"contents"];
		[searchContents enumerateObjectsUsingBlock:^(id key, NSUInteger value, BOOL *stop) {
			NSArray *videoArtworkArray = searchContents[value][@"videoRenderer"][@"thumbnail"][@"thumbnails"];
			NSString *videoArtwork;
			if (videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]) {
				videoArtwork = [NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]];
			}
			NSString *videoTime;
			if (searchContents[value][@"videoRenderer"][@"lengthText"][@"simpleText"]) {
				videoTime = [NSString stringWithFormat:@"%@", searchContents[value][@"videoRenderer"][@"lengthText"][@"simpleText"]];
			}
			NSString *videoTitle;
			if (searchContents[value][@"videoRenderer"][@"title"][@"runs"][0][@"text"]) {
				videoTitle = [NSString stringWithFormat:@"%@", searchContents[value][@"videoRenderer"][@"title"][@"runs"][0][@"text"]];
			}
			NSString *videoCount;
			if (searchContents[value][@"videoRenderer"][@"viewCountText"][@"simpleText"]) {
				videoCount = [NSString stringWithFormat:@"%@", searchContents[value][@"videoRenderer"][@"viewCountText"][@"simpleText"]];
			} else if ([searchContents[value][@"videoRenderer"][@"viewCountText"][@"runs"] count] >= 1) {
				videoCount = [NSString stringWithFormat:@"%@%@", searchContents[value][@"videoRenderer"][@"viewCountText"][@"runs"][0][@"text"], searchContents[value][@"videoRenderer"][@"viewCountText"][@"runs"][1][@"text"]];
			}
			NSString *videoAuthor;
			if (searchContents[value][@"videoRenderer"][@"longBylineText"][@"runs"][0][@"text"]) {
				videoAuthor = [NSString stringWithFormat:@"%@", searchContents[value][@"videoRenderer"][@"longBylineText"][@"runs"][0][@"text"]];
			}
			NSString *videoID;
			if (searchContents[value][@"videoRenderer"][@"videoId"]) {
				videoID = [NSString stringWithFormat:@"%@", searchContents[value][@"videoRenderer"][@"videoId"]];
			}
			NSMutableDictionary *mainDictionary = [NSMutableDictionary new];
			[mainDictionary setValue:videoArtwork forKey:@"artwork"];
			[mainDictionary setValue:videoTime forKey:@"time"];
			[mainDictionary setValue:videoTitle forKey:@"title"];
			[mainDictionary setValue:videoCount forKey:@"count"];
			[mainDictionary setValue:videoAuthor forKey:@"author"];
			[mainDictionary setValue:videoID forKey:@"id"];

			if ([mainDictionary count] != 0) {
				[mainArray addObject:mainDictionary];
			}
		}];
	} else {
		NSArray *videoArtworkArray = youtubePlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
		NSString *videoArtwork;
		if (videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]) {
			videoArtwork = [NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]];
		}
		NSString *videoTime;
		if (youtubePlayerRequest[@"videoDetails"][@"lengthSeconds"]) {
			NSString *videoLength = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"lengthSeconds"]];
			videoTime = [NSString stringWithFormat:@"%d:%02d", [videoLength intValue] / 60, [videoLength intValue] % 60];
		}
		NSString *videoTitle;
		if (youtubePlayerRequest[@"videoDetails"][@"title"]) {
			videoTitle = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"title"]];
		}
		NSString *videoAuthor;
		if (youtubePlayerRequest[@"videoDetails"][@"author"]) {
			videoAuthor = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"author"]];
		}
		NSString *videoID;
		if (youtubePlayerRequest[@"videoDetails"][@"videoId"]) {
			videoID = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"videoId"]];
		}
		NSString *videoLength;
		if (youtubePlayerRequest[@"videoDetails"][@"lengthSeconds"]) {
			videoLength = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"lengthSeconds"]];
		}
		NSMutableDictionary *mainDictionary = [NSMutableDictionary new];
		[mainDictionary setValue:videoArtwork forKey:@"artwork"];
		[mainDictionary setValue:videoTime forKey:@"time"];
		[mainDictionary setValue:videoTitle forKey:@"title"];
		[mainDictionary setValue:videoAuthor forKey:@"author"];
		[mainDictionary setValue:videoLength forKey:@"length"];
		[mainDictionary setValue:videoID forKey:@"id"];

		if ([mainDictionary count] != 0) {
			[mainArray addObject:mainDictionary];
		}
	}
}

- (void)mainViewSetup {
	[scrollView removeFromSuperview];
	scrollView.frame = CGRectMake(boundsWindow.safeAreaInsets.left, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width - boundsWindow.safeAreaInsets.left - boundsWindow.safeAreaInsets.right, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);
	scrollView.refreshControl = [UIRefreshControl new];
    [scrollView.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

	NSArray *infoArray = [mainArray copy];
	__block int viewBounds = 0;
	__block int viewCount = 0;
	[infoArray enumerateObjectsUsingBlock:^(id key, NSUInteger value, BOOL *stop) {
		MainDisplayView *mainDisplayView = [[MainDisplayView alloc] initWithFrame:CGRectMake(0, viewBounds, scrollView.bounds.size.width, 100) array:infoArray position:viewCount save:1];
		[scrollView addSubview:mainDisplayView];
		viewBounds += 102;
		viewCount += 1;
	}];

	scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

	UIInterfaceOrientation orientation = [[[[[UIApplication sharedApplication] windows] firstObject] windowScene] interfaceOrientation];
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

@implementation SearchViewController (Privates)

// Nav Bar

- (void)searchRequest {
	[searchTextField resignFirstResponder];
	[self mainArraySetup];
	[self mainViewSetup];
}

// Scroll View

- (void)refresh:(UIRefreshControl *)refreshControl {
	[self mainArraySetup];
	[self mainViewSetup];
	[scrollView.refreshControl endRefreshing];
	[scrollView setContentOffset:CGPointZero animated:YES];
}

@end