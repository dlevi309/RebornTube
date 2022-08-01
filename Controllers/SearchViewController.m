#import "SearchViewController.h"
#import "PlayerViewController.h"
#import "VlcPlayerViewController.h"
#import "../Classes/YouTubeExtractor.h"

@interface SearchViewController ()
{
	UITextField *searchTextField;
	NSMutableDictionary *searchVideoIDDictionary;
}
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
			searchView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
			searchView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
			searchView.tag = i;
			UITapGestureRecognizer *searchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTap:)];
			searchViewTap.numberOfTapsRequired = 1;
			[searchView addGestureRecognizer:searchViewTap];

			UIImageView *videoImage = [[UIImageView alloc] init];
			videoImage.frame = CGRectMake(0, 0, 80, 80);
            NSArray *videoArtworkArray = searchContents[i][@"compactVideoRenderer"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
			videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
			[searchView addSubview:videoImage];

            UILabel *videoTimeLabel = [[UILabel alloc] init];
			videoTimeLabel.frame = CGRectMake(40, 65, 40, 15);
			videoTimeLabel.text = [NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"lengthText"][@"runs"][0][@"text"]];
            videoTimeLabel.textAlignment = NSTextAlignmentCenter;
			videoTimeLabel.textColor = [UIColor whiteColor];
			videoTimeLabel.numberOfLines = 1;
            videoTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            videoTimeLabel.layer.cornerRadius = 5;
            videoTimeLabel.clipsToBounds = YES;
			videoTimeLabel.adjustsFontSizeToFitWidth = true;
			videoTimeLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoTimeLabel];

			UILabel *videoTitleLabel = [[UILabel alloc] init];
			videoTitleLabel.frame = CGRectMake(85, 0, searchView.frame.size.width - 85, 80);
			videoTitleLabel.text = [NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"title"][@"runs"][0][@"text"]];
			videoTitleLabel.textColor = [UIColor whiteColor];
			videoTitleLabel.numberOfLines = 2;
			videoTitleLabel.adjustsFontSizeToFitWidth = true;
			videoTitleLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoTitleLabel];

            UILabel *videoCountAndAuthorLabel = [[UILabel alloc] init];
			videoCountAndAuthorLabel.frame = CGRectMake(5, 80, searchView.frame.size.width - 5, 20);
			videoCountAndAuthorLabel.text = [NSString stringWithFormat:@"%@ - %@", searchContents[i][@"compactVideoRenderer"][@"viewCountText"][@"runs"][0][@"text"], searchContents[i][@"compactVideoRenderer"][@"longBylineText"][@"runs"][0][@"text"]];
			videoCountAndAuthorLabel.textColor = [UIColor whiteColor];
			videoCountAndAuthorLabel.numberOfLines = 1;
            [videoCountAndAuthorLabel setFont:[UIFont systemFontOfSize:12]];
			videoCountAndAuthorLabel.adjustsFontSizeToFitWidth = true;
			videoCountAndAuthorLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoCountAndAuthorLabel];
			
			[searchVideoIDDictionary setValue:[NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"videoId"]] forKey:[NSString stringWithFormat:@"%d", i]];
			viewBounds += 102;

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
    NSURL *video2160p;
    NSURL *video1440p;
    NSURL *video1080p;
    NSURL *video720p;
    NSURL *video480p;
    NSURL *video360p;
    NSURL *video240p;
    NSURL *audioHigh;
    NSURL *audioMedium;
    NSURL *audioLow;
    for (NSDictionary *format in innertubeAdaptiveFormats) {
        if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"2160"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd2160"]) {
            if (video2160p == nil) {
                video2160p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1440"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1440"]) {
            if (video1440p == nil) {
                video1440p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1080"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1080"]) {
            if (video1080p == nil) {
                video1080p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"720"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd720"]) {
            if (video720p == nil) {
                video720p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"480"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"480p"]) {
            if (video480p == nil) {
                video480p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"360"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"360p"]) {
            if (video360p == nil) {
                video360p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"240"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"240p"]) {
            if (video240p == nil) {
                video240p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_HIGH"]) {
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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableDeveloperOptions"] == YES) {
        if (video240p != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"240p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:video240p:audioURL:nil:sponsorBlockValues];
            }]];
        }
        if (video360p != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"360p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:video360p:audioURL:nil:sponsorBlockValues];
            }]];
        }
        if (video480p != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"480p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:video480p:audioURL:nil:sponsorBlockValues];
            }]];
        }
        if (video720p != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"720p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:video720p:audioURL:nil:sponsorBlockValues];
            }]];
        }
        if (video1080p != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"1080p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:video1080p:audioURL:nil:sponsorBlockValues];
            }]];
        }
        if (video1440p != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"1440p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:video1440p:audioURL:nil:sponsorBlockValues];
            }]];
        }
        if (video2160p != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"2160p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:video2160p:audioURL:nil:sponsorBlockValues];
            }]];
        }
    }
    if (videoStream != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Stream" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:nil:nil:videoStream:sponsorBlockValues];
        }]];
    }
    if (audioURL != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Audio Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self player:videoID:videoTitle:videoLength:videoArtwork:videoViewCount:videoLikes:videoDislikes:nil:audioURL:nil:sponsorBlockValues];
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

- (void)player :(NSString *)videoID :(NSString *)videoTitle :(NSString *)videoLength :(NSURL *)videoArtwork :(NSString *)videoViewCount :(NSString *)videoLikes :(NSString *)videoDislikes :(NSURL *)videoURL :(NSURL *)audioURL :(NSURL *)videoStream :(NSMutableDictionary *)sponsorBlockValues {
    if (videoURL == nil) {
        PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
        playerViewController.videoID = videoID;
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
    } else {
        VlcPlayerViewController *playerViewController = [[VlcPlayerViewController alloc] init];
        playerViewController.videoID = videoID;
        playerViewController.videoTitle = videoTitle;
        playerViewController.videoLength = videoLength;
        playerViewController.videoArtwork = videoArtwork;
        playerViewController.videoViewCount = videoViewCount;
        playerViewController.videoLikes = videoLikes;
        playerViewController.videoDislikes = videoDislikes;
        playerViewController.videoURL = videoURL;
        playerViewController.audioURL = audioURL;
        playerViewController.sponsorBlockValues = sponsorBlockValues;

        UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
        playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:playerViewControllerView animated:YES completion:nil];
    }
}

@end