// Main

#import "VideoHistoryViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/YouTubeExtractor.h"
#import "../../Classes/YouTubeLoader.h"

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

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSMutableDictionary *historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];
    NSMutableArray *historyArray = [historyDictionary objectForKey:self.historyViewID];

    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);
    
    int viewBounds = 0;
    int videoCount = 1;
    for (NSString *videoID in historyArray) {
        NSMutableDictionary *youtubeAndroidPlayerRequest = [YouTubeExtractor youtubeAndroidPlayerRequest:videoID];
        @try {
            UIView *historyView = [[UIView alloc] init];
            historyView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
            historyView.backgroundColor = [AppColours viewBackgroundColour];
            historyView.tag = videoCount;
            UITapGestureRecognizer *historyViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyTap:)];
            historyViewTap.numberOfTapsRequired = 1;
            [historyView addGestureRecognizer:historyViewTap];

            UIImageView *videoImage = [[UIImageView alloc] init];
            videoImage.frame = CGRectMake(0, 0, 80, 80);
            NSArray *videoArtworkArray = youtubeAndroidPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
            videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
            [historyView addSubview:videoImage];

            UILabel *videoTitleLabel = [[UILabel alloc] init];
            videoTitleLabel.frame = CGRectMake(85, 0, historyView.frame.size.width - 85, 80);
            videoTitleLabel.text = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"title"]];
            videoTitleLabel.textColor = [AppColours textColour];
            videoTitleLabel.numberOfLines = 2;
            videoTitleLabel.adjustsFontSizeToFitWidth = YES;
            [historyView addSubview:videoTitleLabel];

            UILabel *videoAuthorLabel = [[UILabel alloc] init];
            videoAuthorLabel.frame = CGRectMake(5, 80, historyView.frame.size.width - 5, 20);
            videoAuthorLabel.text = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"author"]];
            videoAuthorLabel.textColor = [AppColours textColour];
            videoAuthorLabel.numberOfLines = 1;
            [videoAuthorLabel setFont:[UIFont systemFontOfSize:12]];
            videoAuthorLabel.adjustsFontSizeToFitWidth = YES;
            [historyView addSubview:videoAuthorLabel];
            
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
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

// Other

- (void)historyTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *videoID = [videoIDDictionary valueForKey:historyViewTag];
    [YouTubeLoader init:videoID];
}

@end