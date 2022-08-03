// Main

#import "PlaylistsViewController.h"
#import "CreatePlaylistsViewController.h"
#import "VideoPlaylistsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface PlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
    NSMutableDictionary *playlistsIDDictionary;
}
- (void)keysSetup;
@end

@implementation PlaylistsViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *createPlaylistsLabel = [[UILabel alloc] init];
    createPlaylistsLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 40);
    createPlaylistsLabel.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
    createPlaylistsLabel.text = @"Create Playlist";
    createPlaylistsLabel.textColor = [UIColor whiteColor];
    createPlaylistsLabel.numberOfLines = 1;
    createPlaylistsLabel.adjustsFontSizeToFitWidth = true;
    createPlaylistsLabel.adjustsFontForContentSizeCategory = false;
    createPlaylistsLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *createPlaylistsLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createPlaylistsTap:)];
    createPlaylistsLabelTap.numberOfTapsRequired = 1;
    [createPlaylistsLabel addGestureRecognizer:createPlaylistsLabelTap];

    [self.view addSubview:createPlaylistsLabel];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSMutableDictionary *playlistsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + createPlaylistsLabel.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - createPlaylistsLabel.frame.size.height - 50);
    
    int viewBounds = 0;
    int nameCount = 1;
    for (NSString *key in playlistsDictionary) {
        UIView *playlistsView = [[UIView alloc] init];
        playlistsView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        playlistsView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
        playlistsView.tag = nameCount;
        UITapGestureRecognizer *playlistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsTap:)];
        playlistsViewTap.numberOfTapsRequired = 1;
        [playlistsView addGestureRecognizer:playlistsViewTap];

        UILabel *playlistsNameLabel = [[UILabel alloc] init];
        playlistsNameLabel.frame = CGRectMake(10, 0, playlistsView.frame.size.width - 10, playlistsView.frame.size.height);
        playlistsNameLabel.text = key;
        playlistsNameLabel.textColor = [UIColor whiteColor];
        playlistsNameLabel.numberOfLines = 1;
        playlistsNameLabel.adjustsFontSizeToFitWidth = true;
        playlistsNameLabel.adjustsFontForContentSizeCategory = false;
        [playlistsView addSubview:playlistsNameLabel];

        [playlistsIDDictionary setValue:key forKey:[NSString stringWithFormat:@"%d", nameCount]];
        viewBounds += 42;
        nameCount += 1;

        [scrollView addSubview:playlistsView];
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation PlaylistsViewController (Privates)

- (void)createPlaylistsTap:(UITapGestureRecognizer *)recognizer {
    CreatePlaylistsViewController *createPlaylistsViewController = [[CreatePlaylistsViewController alloc] init];

    [self presentViewController:createPlaylistsViewController animated:YES completion:nil];
}

- (void)playlistsTap:(UITapGestureRecognizer *)recognizer {
    NSString *playlistsViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *playlistsViewID = [playlistsIDDictionary valueForKey:playlistsViewTag];

    VideoPlaylistsViewController *playlistsVideosViewController = [[VideoPlaylistsViewController alloc] init];
    playlistsVideosViewController.playlistsViewID = playlistsViewID;
    
    UINavigationController *playlistsVideosViewControllerView = [[UINavigationController alloc] initWithRootViewController:playlistsVideosViewController];
    playlistsVideosViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:playlistsVideosViewControllerView animated:NO completion:nil];
}

@end