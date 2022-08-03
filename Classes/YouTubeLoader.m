#import "YouTubeLoader.h"
#import "AppDelegate.h"
#import "YouTubeExtractor.h"
#import "../Controllers/PlayerViewController.h"

@implementation YouTubeLoader

+ (void)init :(NSString *)videoID {
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
            PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
            playerViewController.videoID = videoID;
            playerViewController.videoTitle = videoTitle;
            playerViewController.videoLength = videoLength;
            playerViewController.videoArtwork = videoArtwork;
            playerViewController.videoViewCount = videoViewCount;
            playerViewController.videoLikes = videoLikes;
            playerViewController.videoDislikes = videoDislikes;
            playerViewController.audioURL = nil;
            playerViewController.videoStream = videoStream;
            playerViewController.sponsorBlockValues = sponsorBlockValues;

            UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
            playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
            UIViewController *vc = [window rootViewController];
            [vc presentViewController:playerViewControllerView animated:YES completion:nil];
        }]];
    }
    if (audioURL != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Audio Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
            playerViewController.videoID = videoID;
            playerViewController.videoTitle = videoTitle;
            playerViewController.videoLength = videoLength;
            playerViewController.videoArtwork = videoArtwork;
            playerViewController.videoViewCount = videoViewCount;
            playerViewController.videoLikes = videoLikes;
            playerViewController.videoDislikes = videoDislikes;
            playerViewController.audioURL = audioURL;
            playerViewController.videoStream = nil;
            playerViewController.sponsorBlockValues = sponsorBlockValues;

            UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
            playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
            UIViewController *vc = [window rootViewController];
            [vc presentViewController:playerViewControllerView animated:YES completion:nil];
        }]];
    }

    [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
    UIViewController *vc = [window rootViewController];
    [vc presentViewController:alertQualitySelector animated:YES completion:nil];
}

@end