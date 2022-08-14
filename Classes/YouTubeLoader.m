#import "YouTubeLoader.h"
#import "YouTubeExtractor.h"
#import "../Controllers/PlayerViewController.h"
#import "../Controllers/Playlists/AddToPlaylistsViewController.h"

@implementation YouTubeLoader

+ (void)init :(NSString *)videoID {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topViewController;
            topViewController = nav.topViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }

    NSMutableDictionary *sponsorBlockValues = [YouTubeExtractor sponsorBlockRequest:videoID];

	NSMutableDictionary *returnYouTubeDislikeRequest = [YouTubeExtractor returnYouTubeDislikeRequest:videoID];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *videoViewCount = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"viewCount"]];
    NSString *videoLikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"likes"]];
    NSString *videoDislikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"dislikes"]];

    NSMutableDictionary *youtubeiOSPlayerRequest = [YouTubeExtractor youtubeiOSPlayerRequest:videoID];
    NSURL *videoStream = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubeiOSPlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
    NSString *videoTitle = [NSString stringWithFormat:@"%@", youtubeiOSPlayerRequest[@"videoDetails"][@"title"]];
    NSString *videoAuthor = [NSString stringWithFormat:@"%@", youtubeiOSPlayerRequest[@"videoDetails"][@"author"]];
    NSString *videoLength = [NSString stringWithFormat:@"%@", youtubeiOSPlayerRequest[@"videoDetails"][@"lengthSeconds"]];
    NSArray *videoArtworkArray = youtubeiOSPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
    NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
    BOOL isLive = youtubeiOSPlayerRequest[@"videoDetails"][@"isLive"];
    NSDictionary *innertubeAdaptiveFormats = youtubeiOSPlayerRequest[@"streamingData"][@"adaptiveFormats"];
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

    UIAlertController *alertQualitySelector;

    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        alertQualitySelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    } else {
        alertQualitySelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    }
    
    if (videoStream != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Stream" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
            // Main Info
            playerViewController.videoID = videoID;
            playerViewController.playbackMode = 1;

            // Player Info
            playerViewController.videoStream = videoStream;
            playerViewController.audioURL = nil;

            // Other Info
            playerViewController.videoTitle = videoTitle;
            playerViewController.videoAuthor = videoAuthor;
            playerViewController.videoLength = videoLength;
            playerViewController.videoArtwork = videoArtwork;
            playerViewController.videoViewCount = videoViewCount;
            playerViewController.videoLikes = videoLikes;
            playerViewController.videoDislikes = videoDislikes;
            playerViewController.sponsorBlockValues = sponsorBlockValues;

            UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
            playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [topViewController presentViewController:playerViewControllerView animated:YES completion:nil];
        }]];
    }

    if (audioURL != nil) {
        if (isLive != true) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Audio Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
                // Main Info
                playerViewController.videoID = videoID;
                playerViewController.playbackMode = 1;

                // Player Info
                playerViewController.videoStream = nil;
                playerViewController.audioURL = audioURL;

                // Other Info
                playerViewController.videoTitle = videoTitle;
                playerViewController.videoAuthor = videoAuthor;
                playerViewController.videoLength = videoLength;
                playerViewController.videoArtwork = videoArtwork;
                playerViewController.videoViewCount = videoViewCount;
                playerViewController.videoLikes = videoLikes;
                playerViewController.videoDislikes = videoDislikes;
                playerViewController.sponsorBlockValues = sponsorBlockValues;

                UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
                playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

                [topViewController presentViewController:playerViewControllerView animated:YES completion:nil];
            }]];
        }
    }

    [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        AddToPlaylistsViewController *addToPlaylistsViewController = [[AddToPlaylistsViewController alloc] init];
        addToPlaylistsViewController.videoID = videoID;

        [topViewController presentViewController:addToPlaylistsViewController animated:YES completion:nil];
    }]];

    [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [topViewController presentViewController:alertQualitySelector animated:YES completion:nil];
}

@end