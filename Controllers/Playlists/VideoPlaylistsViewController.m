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

    // Other
    NSMutableDictionary *videoIDDictionary;
}
- (void)keysSetup;
@end

@implementation VideoPlaylistsViewController

- (void)loadView {
	[super loadView];
    [self keysSetup];
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
        NSMutableDictionary *youtubeAndroidPlayerRequest = [YouTubeExtractor youtubeAndroidPlayerRequest:videoID];
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
            NSArray *videoArtworkArray = youtubeAndroidPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
            videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
            [playlistsView addSubview:videoImage];

            UILabel *videoTitleLabel = [[UILabel alloc] init];
            videoTitleLabel.frame = CGRectMake(85, 0, playlistsView.frame.size.width - 85, 80);
            videoTitleLabel.text = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"title"]];
            videoTitleLabel.textColor = [UIColor whiteColor];
            videoTitleLabel.numberOfLines = 2;
            videoTitleLabel.adjustsFontSizeToFitWidth = true;
            videoTitleLabel.adjustsFontForContentSizeCategory = false;
            [playlistsView addSubview:videoTitleLabel];

            UILabel *videoAuthorLabel = [[UILabel alloc] init];
            videoAuthorLabel.frame = CGRectMake(5, 80, playlistsView.frame.size.width - 5, 20);
            videoAuthorLabel.text = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"author"]];
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
}

@end

@implementation VideoPlaylistsViewController (Privates)

- (void)playlistsTap:(UITapGestureRecognizer *)recognizer {
    NSString *playlistsViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *videoID = [videoIDDictionary valueForKey:playlistsViewTag];
    [YouTubeLoader init:videoID];
}

@end