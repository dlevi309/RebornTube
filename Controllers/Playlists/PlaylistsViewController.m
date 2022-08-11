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
    UILabel *createPlaylistsLabel;
    UIScrollView *scrollView;
}
- (void)keysSetup;
@end

@implementation PlaylistsViewController

- (void)loadView {
	[super loadView];
    [self keysSetup];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    createPlaylistsLabel = [[UILabel alloc] init];
    createPlaylistsLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 40);
    createPlaylistsLabel.backgroundColor = [AppColours viewBackgroundColour];
    createPlaylistsLabel.text = @"Create Playlist";
    createPlaylistsLabel.textColor = [AppColours textColour];
    createPlaylistsLabel.numberOfLines = 1;
    createPlaylistsLabel.adjustsFontSizeToFitWidth = true;
    createPlaylistsLabel.adjustsFontForContentSizeCategory = false;
    createPlaylistsLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *createPlaylistsLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createPlaylistsTap:)];
    createPlaylistsLabelTap.numberOfTapsRequired = 1;
    [createPlaylistsLabel addGestureRecognizer:createPlaylistsLabelTap];

    [self.view addSubview:createPlaylistsLabel];    
}

- (void)viewWillAppear:(BOOL)animated {
    playlistsIDDictionary = [NSMutableDictionary new];
    [scrollView removeFromSuperview];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSMutableDictionary *playlistsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];

    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + createPlaylistsLabel.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - createPlaylistsLabel.frame.size.height - 50);
    
    int viewBounds = 0;
    int nameCount = 1;
    for (NSString *key in playlistsDictionary) {
        UIView *playlistsView = [[UIView alloc] init];
        playlistsView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        playlistsView.backgroundColor = [AppColours viewBackgroundColour];
        playlistsView.tag = nameCount;
        UITapGestureRecognizer *playlistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsTap:)];
        playlistsViewTap.numberOfTapsRequired = 1;
        [playlistsView addGestureRecognizer:playlistsViewTap];

        UILabel *playlistsNameLabel = [[UILabel alloc] init];
        playlistsNameLabel.frame = CGRectMake(10, 0, playlistsView.frame.size.width - 10, playlistsView.frame.size.height);
        playlistsNameLabel.text = key;
        playlistsNameLabel.textColor = [AppColours textColour];
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
    scrollView = [[UIScrollView alloc] init];
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
    
    [self.navigationController pushViewController:playlistsVideosViewController animated:YES];
}

@end