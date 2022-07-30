#import "SearchViewController.h"
#import "PlayerViewController.h"
#import "../Classes/YouTubeExtractor.h"

@interface SearchViewController ()
{
	UITextField *searchTextField;
	NSMutableDictionary *searchVideoIDDictionary;
}
- (void)searchRequest;
- (void)loadRequests :(NSString *)videoID;
- (void)player :(NSString *)videoTitle :(NSString *)videoLength :(NSURL *)videoArtwork :(NSString *)videoViewCount :(NSString *)videoLikes :(NSString *)videoDislikes :(NSURL *)audioURL :(NSURL *)videoStream :(NSMutableDictionary *)sponsorBlockValues;
@end

@implementation SearchViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];

	searchTextField = [[UITextField alloc] init];
	searchTextField.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 60);
	searchTextField.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	searchTextField.placeholder = @"Search Here";
	[searchTextField addTarget:self action:@selector(searchRequest) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.view addSubview:searchTextField];
}

@end

@implementation SearchViewController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchRequest {
	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
	searchVideoIDDictionary = [NSMutableDictionary new];

	NSMutableDictionary *youtubeiAndroidSearchRequest = [YouTubeExtractor youtubeiAndroidSearchRequest:[searchTextField text]];
    NSArray *searchContents = youtubeiAndroidSearchRequest[@"contents"][@"sectionListRenderer"][@"contents"][0][@"itemSectionRenderer"][@"contents"];
	
	UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + searchTextField.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - searchTextField.frame.size.height);
	
	int viewBounds = 0;
	for (int i = 1 ; i <= 50 ; i++) {
		@try {
			UIView *searchView = [[UIView alloc] init];
			searchView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 80);
			searchView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
			searchView.tag = i;
			UITapGestureRecognizer *searchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTap:)];
			searchViewTap.numberOfTapsRequired = 1;
			[searchView addGestureRecognizer:searchViewTap];

			UIImageView *videoImage = [[UIImageView alloc] init];
			videoImage.frame = CGRectMake(0, 0, 80, searchView.frame.size.height);
            NSArray *videoArtworkArray = searchContents[i][@"compactVideoRenderer"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
			videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
			[searchView addSubview:videoImage];

			UILabel *videoTitleLabel = [[UILabel alloc] init];
			videoTitleLabel.frame = CGRectMake(85, 0, searchView.frame.size.width - 85, searchView.frame.size.height);
			videoTitleLabel.text = searchContents[i][@"compactVideoRenderer"][@"title"][@"runs"][0][@"text"];
			videoTitleLabel.textColor = [UIColor whiteColor];
			videoTitleLabel.numberOfLines = 2;
			videoTitleLabel.adjustsFontSizeToFitWidth = true;
			videoTitleLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoTitleLabel];
			
			[searchVideoIDDictionary setValue:[NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"videoId"]] forKey:[NSString stringWithFormat:@"%d", i]];
			viewBounds += 82;

			[scrollView addSubview:searchView];
		}
        @catch (NSException *exception) {
        }
	}

	scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)searchTap:(UITapGestureRecognizer *)recognizer {
	NSString *searchViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *videoID = [searchVideoIDDictionary valueForKey:searchViewTag];

    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];

    NSMutableDictionary *historyDictionary;
    if (![fm fileExistsAtPath:historyPlistFilePath]) {
        historyDictionary = [[NSMutableDictionary alloc] init];
    } else {
        historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];
    }

    NSMutableArray *historyArray;
    if ([historyDictionary objectForKey:date]) {
        historyArray = [historyDictionary objectForKey:date];
    } else {
        historyArray = [[NSMutableArray alloc] init];
    }
    
    [historyArray addObject:videoID];

    [historyDictionary setValue:historyArray forKey:date];

    [historyDictionary writeToFile:historyPlistFilePath atomically:YES];

    [self loadRequests:videoID];
}

- (void)loadRequests :(NSString *)videoID {
    NSMutableDictionary *sponsorBlockValues = [YouTubeExtractor sponsorBlockRequest:videoID];

	NSMutableDictionary *returnYouTubeDislikeRequest = [YouTubeExtractor returnYouTubeDislikeRequest:videoID];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *videoViewCount = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"viewCount"]];
    NSString *videoLikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"likes"]];
    NSString *videoDislikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"dislikes"]];

    NSMutableDictionary *youtubeiiOSPlayerRequest = [YouTubeExtractor youtubeiiOSPlayerRequest:videoID];
    NSURL *videoStream = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubeiiOSPlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];

    NSMutableDictionary *youtubeiAndroidPlayerRequest = [YouTubeExtractor youtubeiAndroidPlayerRequest:videoID];
    NSString *videoTitle = [NSString stringWithFormat:@"%@", youtubeiAndroidPlayerRequest[@"videoDetails"][@"title"]];
    NSString *videoLength = [NSString stringWithFormat:@"%@", youtubeiAndroidPlayerRequest[@"videoDetails"][@"lengthSeconds"]];
    NSArray *videoArtworkArray = youtubeiAndroidPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
    NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
    NSDictionary *innertubeAdaptiveFormats = youtubeiAndroidPlayerRequest[@"streamingData"][@"adaptiveFormats"];
    NSURL *audioHigh;
    NSURL *audioMedium;
    NSURL *audioLow;
    for (NSDictionary *format in innertubeAdaptiveFormats) {
        if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_HIGH"]) {
            if (audioHigh == nil) {
                audioHigh = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_MEDIUM"]) {
            if (audioMedium == nil) {
                audioMedium = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_LOW"]) {
            if (audioLow == nil) {
                audioLow = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        }
    }

    NSURL *audioURL;
    if (audioHigh != nil) {
        audioURL = audioHigh;
    } else if (audioMedium != nil) {
        audioURL = audioMedium;
    } else if (audioLow != nil) {
        audioURL = audioLow;
    }

    UIAlertController *alertQualitySelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (videoStream != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Stream" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self player:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:nil:videoStream:sponsorBlockValues];
        }]];
    }
    if (audioURL != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Audio Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self player:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:audioURL:nil:sponsorBlockValues];
        }]];
    }

    [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertQualitySelector setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertQualitySelector popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;

    [self presentViewController:alertQualitySelector animated:YES completion:nil];
}

- (void)player :(NSString *)videoTitle :(NSString *)videoLength :(NSURL *)videoArtwork :(NSString *)videoViewCount :(NSString *)videoLikes :(NSString *)videoDislikes :(NSURL *)audioURL :(NSURL *)videoStream :(NSMutableDictionary *)sponsorBlockValues {
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.videoTitle = videoTitle;
    playerViewController.videoLength = videoLength;
    playerViewController.videoArtwork = videoArtwork;
    playerViewController.videoViewCount = videoViewCount;
    playerViewController.videoLikes = videoLikes;
    playerViewController.videoDislikes = videoDislikes;
    playerViewController.audioURL = audioURL;
    playerViewController.videoStream = videoStream;
    playerViewController.sponsorBlockValues = sponsorBlockValues;

    UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
    playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:playerViewControllerView animated:YES completion:nil];
}

@end