// Main

#import "PlaylistsViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"
#import "../Settings/SettingsNavigationController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppFonts.h"

// Controllers

#import "CreatePlaylistsViewController.h"

// Views

#import "../../Views/MainMiniDisplayView.h"

// Interface

@interface PlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    UIScrollView *scrollView;
    
    // Main Array
    NSArray *mainArray;
}
- (void)keysSetup;
- (void)navBarSetup;
- (void)mainArraySetup;
- (void)mainViewSetup;
@end

@implementation PlaylistsViewController

- (void)loadView {
	[super loadView];

    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
	[self navBarSetup];
    [self mainArraySetup];
    [self mainViewSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
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

- (void)mainArraySetup {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *plistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    mainArray = [[plistDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)mainViewSetup {
	UIView *createPlaylistsView = [[UIView alloc] init];
	createPlaylistsView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 40);
	createPlaylistsView.backgroundColor = [AppColours viewBackgroundColour];
	createPlaylistsView.userInteractionEnabled = YES;
    UITapGestureRecognizer *createPlaylistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createPlaylistsTap:)];
    createPlaylistsViewTap.numberOfTapsRequired = 1;
    [createPlaylistsView addGestureRecognizer:createPlaylistsViewTap];
	
	UILabel *createPlaylistsLabel = [[UILabel alloc] init];
    createPlaylistsLabel.frame = CGRectMake(10, 0, createPlaylistsView.frame.size.width - 10, createPlaylistsView.frame.size.height);
    createPlaylistsLabel.text = @"Create Playlist";
    createPlaylistsLabel.textColor = [AppColours textColour];
    createPlaylistsLabel.numberOfLines = 1;
	[createPlaylistsLabel setFont:[AppFonts mainFont:createPlaylistsLabel.font.pointSize]];
    createPlaylistsLabel.adjustsFontSizeToFitWidth = YES;
    [createPlaylistsView addSubview:createPlaylistsLabel];

	[self.view addSubview:createPlaylistsView];

	[scrollView removeFromSuperview];
	scrollView.frame = CGRectMake(boundsWindow.safeAreaInsets.left, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + createPlaylistsLabel.frame.size.height + 2, self.view.bounds.size.width - boundsWindow.safeAreaInsets.left - boundsWindow.safeAreaInsets.right, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - createPlaylistsLabel.frame.size.height - 2);
	scrollView.refreshControl = [UIRefreshControl new];
    [scrollView.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

	__block int viewBounds = 0;
	__block int viewCount = 0;
	[mainArray enumerateObjectsUsingBlock:^(id key, NSUInteger value, BOOL *stop) {
		MainMiniDisplayView *mainMiniDisplayView = [[MainMiniDisplayView alloc] initWithFrame:CGRectMake(0, viewBounds, scrollView.bounds.size.width, 40) array:mainArray position:viewCount viewcontroller:1];
		[scrollView addSubview:mainMiniDisplayView];
		viewBounds += 42;
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

@implementation PlaylistsViewController (Privates)

// Nav Bar

- (void)search {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];

	[self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	SettingsNavigationController *settingsNavigationController = [[SettingsNavigationController alloc] initWithRootViewController:settingsViewController];
    
	[self presentViewController:settingsNavigationController animated:YES completion:nil];
}

// Create Playlists

- (void)createPlaylistsTap:(UITapGestureRecognizer *)recognizer {
    CreatePlaylistsViewController *createPlaylistsViewController = [[CreatePlaylistsViewController alloc] init];

    [self.navigationController pushViewController:createPlaylistsViewController animated:YES];
}

// Scroll View

- (void)refresh:(UIRefreshControl *)refreshControl {
	[self mainArraySetup];
	[self mainViewSetup];
	[scrollView.refreshControl endRefreshing];
	[scrollView setContentOffset:CGPointZero animated:YES];
}

@end