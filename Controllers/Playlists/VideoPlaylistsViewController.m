// Main

#import "VideoPlaylistsViewController.h"
#import "PlaylistsViewController.h"

// Classes

#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"
#import "../../Classes/AppColours.h"

// Interface

@interface VideoPlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    NSString *playlistsAssetsBundlePath;
	NSBundle *playlistsAssetsBundle;

    // Other
    NSMutableDictionary *videoIDDictionary;
}
- (void)keysSetup;
@end

@implementation VideoPlaylistsViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [self keysSetup];

    UIImageView *backImage = [[UIImageView alloc] init];
	NSString *backImagePath = [playlistsAssetsBundle pathForResource:@"back" ofType:@"png"];
	backImage.image = [[UIImage imageWithContentsOfFile:backImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	backImage.tintColor = [UIColor whiteColor];
    backImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *backViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
	backViewTap.numberOfTapsRequired = 1;
	[backImage addGestureRecognizer:backViewTap];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backImage];

    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    videoIDDictionary = [NSMutableDictionary new];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSMutableDictionary *playlistsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];
    NSMutableArray *playlistsArray = [playlistsDictionary objectForKey:self.playlistsViewID];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - 50);
    
    int viewBounds = 0;
    int videoCount = 1;
    for (NSString *videoID in playlistsArray) {
        NSMutableDictionary *youtubeiAndroidPlayerRequest = [YouTubeExtractor youtubeiAndroidPlayerRequest:videoID];
        @try {
            UIView *playlistsView = [[UIView alloc] init];
            playlistsView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
            playlistsView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
            playlistsView.tag = videoCount;
            UITapGestureRecognizer *playlistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsTap:)];
            playlistsViewTap.numberOfTapsRequired = 1;
            [playlistsView addGestureRecognizer:playlistsViewTap];

            UIImageView *videoImage = [[UIImageView alloc] init];
            videoImage.frame = CGRectMake(0, 0, 80, 80);
            NSArray *videoArtworkArray = youtubeiAndroidPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
            videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
            [playlistsView addSubview:videoImage];

            UILabel *videoTitleLabel = [[UILabel alloc] init];
            videoTitleLabel.frame = CGRectMake(85, 0, playlistsView.frame.size.width - 85, 80);
            videoTitleLabel.text = [NSString stringWithFormat:@"%@", youtubeiAndroidPlayerRequest[@"videoDetails"][@"title"]];
            videoTitleLabel.textColor = [UIColor whiteColor];
            videoTitleLabel.numberOfLines = 2;
            videoTitleLabel.adjustsFontSizeToFitWidth = true;
            videoTitleLabel.adjustsFontForContentSizeCategory = false;
            [playlistsView addSubview:videoTitleLabel];

            UILabel *videoAuthorLabel = [[UILabel alloc] init];
            videoAuthorLabel.frame = CGRectMake(5, 80, playlistsView.frame.size.width - 5, 20);
            videoAuthorLabel.text = [NSString stringWithFormat:@"%@", youtubeiAndroidPlayerRequest[@"videoDetails"][@"author"]];
            videoAuthorLabel.textColor = [UIColor whiteColor];
            videoAuthorLabel.numberOfLines = 1;
            [videoAuthorLabel setFont:[UIFont systemFontOfSize:12]];
            videoAuthorLabel.adjustsFontSizeToFitWidth = true;
            videoAuthorLabel.adjustsFontForContentSizeCategory = false;
            [playlistsView addSubview:videoAuthorLabel];
            
            [videoIDDictionary setValue:videoID forKey:[NSString stringWithFormat:@"%d", videoCount]];
            viewBounds += 102;
            videoCount += 1;

            [scrollView addSubview:playlistsView];
        }
        @catch (NSException *exception) {
        }
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
    playlistsAssetsBundlePath = [[NSBundle mainBundle] pathForResource:@"PlaylistsAssets" ofType:@"bundle"];
	playlistsAssetsBundle = [NSBundle bundleWithPath:playlistsAssetsBundlePath];
}

@end

@implementation VideoPlaylistsViewController (Privates)

- (void)back:(UITapGestureRecognizer *)recognizer {
    PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc] init];
    
    UINavigationController *playlistsViewControllerView = [[UINavigationController alloc] initWithRootViewController:playlistsViewController];
    playlistsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:playlistsViewControllerView animated:NO completion:nil];
}

- (void)historyTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *videoID = [videoIDDictionary valueForKey:historyViewTag];
    [YouTubeLoader init:videoID];
}

@end