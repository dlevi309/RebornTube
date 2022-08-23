// Main

#import "VideoPlaylistsViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"

// Other

#import "AddToPlaylistsViewController.h"

// Interface

@interface VideoPlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    UIScrollView *scrollView;

    // Other
    NSMutableDictionary *videoIDDictionary;
}
- (void)keysSetup;
- (void)navBarSetup;
@end

@implementation VideoPlaylistsViewController

- (void)loadView {
	[super loadView];

    self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
    [self navBarSetup];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
    scrollView = [[UIScrollView alloc] init];
}

- (void)navBarSetup {
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    
    self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    videoIDDictionary = [NSMutableDictionary new];
    [scrollView removeFromSuperview];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSMutableDictionary *playlistsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];
    NSMutableArray *playlistsArray = [playlistsDictionary objectForKey:self.playlistsViewID];

    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);
    
    int viewBounds = 0;
    int videoCount = 1;
    for (NSString *videoID in playlistsArray) {
        NSMutableDictionary *youtubeAndroidPlayerRequest = [YouTubeExtractor youtubeAndroidPlayerRequest:videoID];
        @try {
            UIView *playlistsView = [[UIView alloc] init];
            playlistsView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
            playlistsView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
            playlistsView.tag = videoCount;
            playlistsView.userInteractionEnabled = YES;
            UITapGestureRecognizer *playlistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsTap:)];
            playlistsViewTap.numberOfTapsRequired = 1;
            [playlistsView addGestureRecognizer:playlistsViewTap];

            UIImageView *videoImage = [[UIImageView alloc] init];
            videoImage.frame = CGRectMake(0, 0, 80, 80);
            NSArray *videoArtworkArray = youtubeAndroidPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
            videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
            [playlistsView addSubview:videoImage];

            NSString *videoLength = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"lengthSeconds"]];
            UILabel *videoTimeLabel = [[UILabel alloc] init];
            videoTimeLabel.frame = CGRectMake(40, 65, 40, 15);
            videoTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", [videoLength intValue] / 60, [videoLength intValue] % 60];
            videoTimeLabel.textAlignment = NSTextAlignmentCenter;
            videoTimeLabel.textColor = [UIColor whiteColor];
            videoTimeLabel.numberOfLines = 1;
            videoTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            videoTimeLabel.layer.cornerRadius = 5;
            videoTimeLabel.clipsToBounds = YES;
            videoTimeLabel.adjustsFontSizeToFitWidth = YES;
            [playlistsView addSubview:videoTimeLabel];

            UILabel *videoTitleLabel = [[UILabel alloc] init];
            videoTitleLabel.frame = CGRectMake(85, 0, playlistsView.frame.size.width - 85, 80);
            videoTitleLabel.text = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"title"]];
            videoTitleLabel.textColor = [UIColor whiteColor];
            videoTitleLabel.numberOfLines = 2;
            videoTitleLabel.adjustsFontSizeToFitWidth = YES;
            [playlistsView addSubview:videoTitleLabel];

            UILabel *videoAuthorLabel = [[UILabel alloc] init];
            videoAuthorLabel.frame = CGRectMake(5, 80, playlistsView.frame.size.width - 45, 20);
            videoAuthorLabel.text = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"author"]];
            videoAuthorLabel.textColor = [UIColor whiteColor];
            videoAuthorLabel.numberOfLines = 1;
            [videoAuthorLabel setFont:[UIFont systemFontOfSize:12]];
            videoAuthorLabel.adjustsFontSizeToFitWidth = YES;
            [playlistsView addSubview:videoAuthorLabel];

            UILabel *videoActionLabel = [[UILabel alloc] init];
            videoActionLabel.frame = CGRectMake(playlistsView.frame.size.width - 30, 80, 20, 20);
            videoActionLabel.tag = videoCount;
            videoActionLabel.text = @"•••";
            videoActionLabel.textAlignment = NSTextAlignmentCenter;
            videoActionLabel.textColor = [AppColours textColour];
            videoActionLabel.numberOfLines = 1;
            [videoActionLabel setFont:[UIFont systemFontOfSize:12]];
            videoActionLabel.adjustsFontSizeToFitWidth = YES;
            videoActionLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *videoActionLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsActionTap:)];
            videoActionLabelTap.numberOfTapsRequired = 1;
            [videoActionLabel addGestureRecognizer:videoActionLabelTap];
            [playlistsView addSubview:videoActionLabel];
            
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

@end

@implementation VideoPlaylistsViewController (Privates)

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

- (void)playlistsTap:(UITapGestureRecognizer *)recognizer {
    NSString *playlistsViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *videoID = [videoIDDictionary valueForKey:playlistsViewTag];
    [YouTubeLoader init:videoID];
}

- (void)playlistsActionTap:(UITapGestureRecognizer *)recognizer {
    NSString *playlistsViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *videoID = [videoIDDictionary valueForKey:playlistsViewTag];

    UIAlertController *alertSelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoID]];
	
		UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
		[self presentViewController:shareSheet animated:YES completion:nil];
    }]];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		AddToPlaylistsViewController *addToPlaylistsViewController = [[AddToPlaylistsViewController alloc] init];
		addToPlaylistsViewController.videoID = videoID;

		[self presentViewController:addToPlaylistsViewController animated:YES completion:nil];
    }]];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertSelector setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertSelector popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;
    popPresenter.permittedArrowDirections = 0;

    [self presentViewController:alertSelector animated:YES completion:nil];
}

@end