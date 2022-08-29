// Main

#import "PlaylistsViewController.h"
#import "CreatePlaylistsViewController.h"
#import "VideoPlaylistsViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface PlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    UIScrollView *scrollView;

    // Other
    NSMutableDictionary *playlistsIDDictionary;
    UILabel *createPlaylistsLabel;
}
- (void)keysSetup;
- (void)navBarSetup;
@end

@implementation PlaylistsViewController

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

    createPlaylistsLabel = [[UILabel alloc] init];
    createPlaylistsLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 40);
    createPlaylistsLabel.backgroundColor = [AppColours viewBackgroundColour];
    createPlaylistsLabel.text = @"Create Playlist";
    createPlaylistsLabel.textColor = [AppColours textColour];
    createPlaylistsLabel.numberOfLines = 1;
    createPlaylistsLabel.adjustsFontSizeToFitWidth = YES;
    createPlaylistsLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *createPlaylistsLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createPlaylistsTap:)];
    createPlaylistsLabelTap.numberOfTapsRequired = 1;
    [createPlaylistsLabel addGestureRecognizer:createPlaylistsLabelTap];

    [self.view addSubview:createPlaylistsLabel];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    playlistsIDDictionary = [NSMutableDictionary new];
    [scrollView removeFromSuperview];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSDictionary *playlistsDictionary = [NSDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];
    NSArray *playlistsDictionarySorted = [[playlistsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + createPlaylistsLabel.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - createPlaylistsLabel.frame.size.height);
    
    int viewBounds = 0;
    int nameCount = 1;
    for (NSString *key in playlistsDictionarySorted) {
        UIView *playlistsView = [[UIView alloc] init];
        playlistsView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        playlistsView.backgroundColor = [AppColours viewBackgroundColour];
        playlistsView.tag = nameCount;
        playlistsView.userInteractionEnabled = YES;
        UITapGestureRecognizer *playlistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsTap:)];
        playlistsViewTap.numberOfTapsRequired = 1;
        [playlistsView addGestureRecognizer:playlistsViewTap];

        UILabel *playlistsNameLabel = [[UILabel alloc] init];
        playlistsNameLabel.frame = CGRectMake(10, 0, playlistsView.frame.size.width - 10, playlistsView.frame.size.height);
        playlistsNameLabel.text = key;
        playlistsNameLabel.textColor = [AppColours textColour];
        playlistsNameLabel.numberOfLines = 1;
        playlistsNameLabel.adjustsFontSizeToFitWidth = YES;
        [playlistsView addSubview:playlistsNameLabel];

        [playlistsIDDictionary setValue:key forKey:[NSString stringWithFormat:@"%d", nameCount]];
        viewBounds += 42;
        nameCount += 1;

        [scrollView addSubview:playlistsView];
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
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
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

// Other

- (void)createPlaylistsTap:(UITapGestureRecognizer *)recognizer {
    CreatePlaylistsViewController *createPlaylistsViewController = [[CreatePlaylistsViewController alloc] init];

    [self.navigationController pushViewController:createPlaylistsViewController animated:YES];
}

- (void)playlistsTap:(UITapGestureRecognizer *)recognizer {
    NSString *playlistsViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *playlistsViewID = [playlistsIDDictionary valueForKey:playlistsViewTag];

    VideoPlaylistsViewController *playlistsVideosViewController = [[VideoPlaylistsViewController alloc] init];
    playlistsVideosViewController.playlistsViewID = playlistsViewID;
    
    [self.navigationController pushViewController:playlistsVideosViewController animated:YES];
}

@end