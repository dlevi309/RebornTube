// Main

#import "AddToPlaylistsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppFonts.h"

// Views

#import "../../Views/MainMiniDisplayView.h"

// Interface

@interface AddToPlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    UIScrollView *scrollView;

    // Main Array
    NSArray *mainArray;

    // Other
    UIButton *closeButton;
}
- (void)keysSetup;
- (void)mainArraySetup;
- (void)mainViewSetup;
@end

@implementation AddToPlaylistsViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];
    
    [self keysSetup];
    [self mainArraySetup];
    [self mainViewSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
    scrollView = [[UIScrollView alloc] init];
    closeButton = [[UIButton alloc] init];
}

- (void)mainArraySetup {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *plistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    mainArray = [[plistDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)mainViewSetup {
    [closeButton removeFromSuperview];
    closeButton.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 40);
    [closeButton addTarget:self action:@selector(closeTap:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
	[closeButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
	[closeButton.titleLabel setFont:[AppFonts mainFont:closeButton.titleLabel.font.pointSize]];
    closeButton.backgroundColor = [AppColours viewBackgroundColour];
	closeButton.layer.cornerRadius = 5;
    [self.view addSubview:closeButton];

    [scrollView removeFromSuperview];
	scrollView.frame = CGRectMake(boundsWindow.safeAreaInsets.left, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + closeButton.frame.size.height + 10, self.view.bounds.size.width - boundsWindow.safeAreaInsets.left - boundsWindow.safeAreaInsets.right, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - closeButton.frame.size.height - 10);
	scrollView.refreshControl = [UIRefreshControl new];
    [scrollView.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

	__block int viewBounds = 0;
	__block int viewCount = 0;
	[mainArray enumerateObjectsUsingBlock:^(id key, NSUInteger value, BOOL *stop) {
		MainMiniDisplayView *mainMiniDisplayView = [[MainMiniDisplayView alloc] initWithFrame:CGRectMake(0, viewBounds, scrollView.bounds.size.width, 40) videoid:self.videoID array:mainArray position:viewCount viewcontroller:2];
        [scrollView addSubview:mainMiniDisplayView];
		viewBounds += 42;
		viewCount += 1;
	}];

	scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)viewDidLoad {
    if (@available(iOS 13.0, *)) {
        self.modalInPresentation = YES;
    }
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

@implementation AddToPlaylistsViewController (Privates)

// Scroll View

- (void)refresh:(UIRefreshControl *)refreshControl {
	[self mainArraySetup];
	[self mainViewSetup];
	[scrollView.refreshControl endRefreshing];
	[scrollView setContentOffset:CGPointZero animated:YES];
}

// Other

- (void)closeTap:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end