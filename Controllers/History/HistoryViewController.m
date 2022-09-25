// Main

#import "HistoryViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"
#import "../Settings/SettingsNavigationController.h"

// Classes

#import "../../Classes/AppColours.h"

// Views

#import "../../Views/MainMiniDisplayView.h"

// Interface

@interface HistoryViewController ()
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

@implementation HistoryViewController

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
	mainArray = [NSMutableArray new];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *plistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    NSEnumerator *plistDictionarySorted = [[[plistDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] reverseObjectEnumerator];
	for (NSString *key in plistDictionarySorted) {
		[mainArray addObject:key];
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
		MainMiniDisplayView *mainMiniDisplayView = [[MainMiniDisplayView alloc] initWithFrame:CGRectMake(0, viewBounds, scrollView.bounds.size.width, 40) videoid:nil array:infoArray position:viewCount viewcontroller:0];
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

@implementation HistoryViewController (Privates)

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

// Scroll View

- (void)refresh:(UIRefreshControl *)refreshControl {
	[self mainArraySetup];
	[self mainViewSetup];
	[scrollView.refreshControl endRefreshing];
	[scrollView setContentOffset:CGPointZero animated:YES];
}

@end