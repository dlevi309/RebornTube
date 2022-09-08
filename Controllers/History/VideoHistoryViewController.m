// Main

#import "VideoHistoryViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"

// Other

#import "../Playlists/AddToPlaylistsViewController.h"

// Interface

@interface VideoHistoryViewController ()
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

@implementation VideoHistoryViewController

- (void)loadView {
	[super loadView];

    self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
    [self navBarSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
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

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSDictionary *historyDictionary = [NSDictionary dictionaryWithContentsOfFile:historyPlistFilePath];
    NSArray *historyArray = [historyDictionary objectForKey:self.historyViewID];

    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);
    
    int viewBounds = 0;
    int videoCount = 1;
    for (NSString *videoID in historyArray) {
        NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"ANDROID":@"16.20":videoID];
        @try {
            UIView *historyView = [[UIView alloc] init];
            historyView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
            historyView.backgroundColor = [AppColours viewBackgroundColour];
            historyView.tag = videoCount;
            historyView.userInteractionEnabled = YES;
            UITapGestureRecognizer *historyViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyTap:)];
            historyViewTap.numberOfTapsRequired = 1;
            [historyView addGestureRecognizer:historyViewTap];

            UIImageView *videoImage = [[UIImageView alloc] init];
            videoImage.frame = CGRectMake(0, 0, 80, 80);
            NSArray *videoArtworkArray = youtubePlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
            videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
            [historyView addSubview:videoImage];

            NSString *videoLength = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"lengthSeconds"]];
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
            [historyView addSubview:videoTimeLabel];

            UILabel *videoTitleLabel = [[UILabel alloc] init];
            videoTitleLabel.frame = CGRectMake(85, 0, historyView.frame.size.width - 85, 80);
            videoTitleLabel.text = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"title"]];
            videoTitleLabel.textColor = [AppColours textColour];
            videoTitleLabel.numberOfLines = 2;
            videoTitleLabel.adjustsFontSizeToFitWidth = YES;
            [historyView addSubview:videoTitleLabel];

            UILabel *videoAuthorLabel = [[UILabel alloc] init];
            videoAuthorLabel.frame = CGRectMake(5, 80, historyView.frame.size.width - 45, 20);
            videoAuthorLabel.text = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"author"]];
            videoAuthorLabel.textColor = [AppColours textColour];
            videoAuthorLabel.numberOfLines = 1;
            [videoAuthorLabel setFont:[UIFont systemFontOfSize:12]];
            videoAuthorLabel.adjustsFontSizeToFitWidth = YES;
            [historyView addSubview:videoAuthorLabel];

            UILabel *videoActionLabel = [[UILabel alloc] init];
            videoActionLabel.frame = CGRectMake(historyView.frame.size.width - 30, 80, 20, 20);
            videoActionLabel.tag = videoCount;
            videoActionLabel.text = @"•••";
            videoActionLabel.textAlignment = NSTextAlignmentCenter;
            videoActionLabel.textColor = [AppColours textColour];
            videoActionLabel.numberOfLines = 1;
            [videoActionLabel setFont:[UIFont systemFontOfSize:12]];
            videoActionLabel.adjustsFontSizeToFitWidth = YES;
            videoActionLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *videoActionLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyActionTap:)];
            videoActionLabelTap.numberOfTapsRequired = 1;
            [videoActionLabel addGestureRecognizer:videoActionLabelTap];
            [historyView addSubview:videoActionLabel];
            
            [videoIDDictionary setValue:videoID forKey:[NSString stringWithFormat:@"%d", videoCount]];
            viewBounds += 102;
            videoCount += 1;

            [scrollView addSubview:historyView];
        }
        @catch (NSException *exception) {
        }
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

@end

@implementation VideoHistoryViewController (Privates)

// Nav Bar

- (void)search {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];

	UINavigationController *searchViewControllerView = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:searchViewControllerView animated:YES completion:nil];
}

- (void)settings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];

	UINavigationController *settingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:settingsViewControllerView animated:YES completion:nil];
}

// Other

- (void)historyTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *videoID = [videoIDDictionary valueForKey:historyViewTag];
    [YouTubeLoader init:videoID];
}

- (void)historyActionTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *videoID = [videoIDDictionary valueForKey:historyViewTag];

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