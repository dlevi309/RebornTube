// Main

#import "VideoPlaylistsViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/YouTubeExtractor.h"

// Views

#import "../../Views/MainDisplayView.h"

// Interface

@interface VideoPlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
	UIScrollView *scrollView;

    // Main Array
    NSMutableArray *mainArray;
}
- (void)keysSetup;
- (void)navBarSetup;
- (void)mainArraySetup;
- (void)mainViewSetup;
@end

@implementation VideoPlaylistsViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];

	[self keysSetup];
	[self navBarSetup];
	[self mainArraySetup];
	[self mainViewSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] lastObject];
	scrollView = [[UIScrollView alloc] init];
}

- (void)navBarSetup {
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    
    self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];
}

- (void)mainArraySetup {
	mainArray = [NSMutableArray new];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *plistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSArray *plistArray = [[NSDictionary dictionaryWithContentsOfFile:plistFilePath] objectForKey:self.entryID];

	[plistArray enumerateObjectsUsingBlock:^(id key, NSUInteger value, BOOL *stop) {
		NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"ANDROID":@"16.20":key];
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
		[mainDictionary setValue:key forKey:@"id"];

		if ([mainDictionary count] != 0) {
			[mainArray addObject:mainDictionary];
		}
	}];
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
		MainDisplayView *mainDisplayView = [[MainDisplayView alloc] initWithFrame:CGRectMake(0, viewBounds, scrollView.bounds.size.width, 100) array:infoArray position:viewCount save:0];
		[scrollView addSubview:mainDisplayView];
		viewBounds += 102;
		viewCount += 1;
	}];

	scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

@end

@implementation VideoPlaylistsViewController (Privates)

// Nav Bar

- (void)search {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];

	[self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];

	UINavigationController *settingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:settingsViewControllerView animated:YES completion:nil];
}

// Scroll View

- (void)refresh:(UIRefreshControl *)refreshControl {
	[self mainArraySetup];
	[self mainViewSetup];
	[scrollView.refreshControl endRefreshing];
	[scrollView setContentOffset:CGPointZero animated:YES];
}

@end