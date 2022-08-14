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

    NSMutableDictionary *youtubeAndroidPlayerRequest = [YouTubeExtractor youtubeAndroidPlayerRequest:videoID];
    NSString *videoTitle = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"title"]];
    NSString *videoAuthor = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"author"]];
    NSString *videoLength = [NSString stringWithFormat:@"%@", youtubeAndroidPlayerRequest[@"videoDetails"][@"lengthSeconds"]];
    NSArray *videoArtworkArray = youtubeAndroidPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
    NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
    BOOL isLive = youtubeAndroidPlayerRequest[@"videoDetails"][@"isLive"];

    NSDictionary *innertubeFormats = youtubeAndroidPlayerRequest[@"streamingData"][@"formats"];
    NSURL *video2160p;
    NSURL *video1440p;
    NSURL *video1080p;
    NSURL *video720p;
    NSURL *video480p;
    NSURL *video360p;
    NSURL *video240p;
    for (NSDictionary *format in innertubeFormats) {
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
        }
    }

    NSURL *videoURL;
    if (video2160p != nil) {
        videoURL = video2160p;
    } else if (video1440p != nil) {
        videoURL = video1440p;
    } else if (video1080p != nil) {
        videoURL = video1080p;
    } else if (video720p != nil) {
        videoURL = video720p;
    } else if (video480p != nil) {
        videoURL = video480p;
    } else if (video360p != nil) {
        videoURL = video360p;
    } else if (video240p != nil) {
        videoURL = video240p;
    }

    NSDictionary *innertubeAdaptiveFormats = youtubeAndroidPlayerRequest[@"streamingData"][@"adaptiveFormats"];
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
    
    if (isLive == true) {
        if (videoStream != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Stream" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
                // Main Info
                playerViewController.videoID = videoID;
                playerViewController.playbackMode = 1;

                // Player Info
                playerViewController.videoStream = videoStream;
                playerViewController.videoURL = nil;
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
    } else {
        if (videoURL != nil) {
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
                // Main Info
                playerViewController.videoID = videoID;
                playerViewController.playbackMode = 2;

                // Player Info
                playerViewController.videoStream = nil;
                playerViewController.videoURL = videoURL;
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
            [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Audio Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
                // Main Info
                playerViewController.videoID = videoID;
                playerViewController.playbackMode = 3;

                // Player Info
                playerViewController.videoStream = nil;
                playerViewController.videoURL = nil;
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