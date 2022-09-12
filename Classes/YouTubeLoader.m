#import "YouTubeLoader.h"
#import "EUCheck.h"
#import "YouTubeExtractor.h"
#import "../Views/MainPopupView.h"
#import "../Controllers/Player/PlayerViewController.h"

// Top View Controller
UIViewController *topViewController;

// Request Response
NSDictionary *youtubePlayerRequest;

// Video Info
NSURL *videoURL;
BOOL videoLiveOrAgeRestricted;
NSString *videoTitle;
NSString *videoAuthor;
NSString *videoLength;
NSURL *videoArtwork;
NSString *videoViewCount;
NSString *videoLikes;
NSString *videoDislikes;
NSDictionary *sponsorBlockValues;

@implementation YouTubeLoader

+ (void)init :(NSString *)videoID {
    [self resetLoaderKeys];
    [self getTopViewController];

    youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"ANDROID":@"16.20":videoID];
    NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
    if ([playabilityStatus isEqual:@"OK"]) {
        BOOL isLive = youtubePlayerRequest[@"videoDetails"][@"isLive"];
        if (isLive) {
            videoLiveOrAgeRestricted = 1;
            videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
        } else if (!isLive) {
            videoLiveOrAgeRestricted = 0;
            [self getVideoUrl];
        }
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentPlayer:videoID];
    } else if ([playabilityStatus isEqual:@"LOGIN_REQUIRED"]) {
        BOOL isLocatedInEU = [EUCheck isLocatedInEU];
        if (isLocatedInEU) {
            UIWindow *boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
            (void)[[MainPopupView alloc] initWithFrame:CGRectMake(20, topViewController.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 80, topViewController.view.bounds.size.width - 40, 80) message:@"Age Restricted Videos Are Unsupported In The EU"];
        } else {
            youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"TVHTML5_SIMPLY_EMBEDDED_PLAYER":@"2.0":videoID];
            BOOL isLive = youtubePlayerRequest[@"videoDetails"][@"isLive"];
            if (isLive) {
                videoLiveOrAgeRestricted = 1;
                videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
            } else if (!isLive) {
                videoLiveOrAgeRestricted = 1;
                [self getVideoUrl];
            }
            [self getVideoInfo];
            [self getReturnYouTubeDislikesInfo:videoID];
            [self getSponsorBlockInfo:videoID];
            [self presentPlayer:videoID];
        }
    } else {
        UIWindow *boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
        (void)[[MainPopupView alloc] initWithFrame:CGRectMake(20, topViewController.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 80, topViewController.view.bounds.size.width - 40, 80) message:@"Video Unsupported"];
    }
}

+ (void)resetLoaderKeys {
    // Top View Controller
    topViewController = nil;

    // Request Response
    youtubePlayerRequest = nil;

    // Video Info
    videoURL = nil;
    videoLiveOrAgeRestricted = 0;
    videoTitle = nil;
    videoAuthor = nil;
    videoLength = nil;
    videoArtwork = nil;
    videoViewCount = nil;
    videoLikes = nil;
    videoDislikes = nil;
    sponsorBlockValues = nil;
}

+ (void)getTopViewController {
    topViewController = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
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
}

+ (void)getVideoUrl {
    NSDictionary *innertubeFormats = youtubePlayerRequest[@"streamingData"][@"formats"];
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
}

+ (void)getVideoInfo {
    videoTitle = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"title"]];
    videoAuthor = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"author"]];
    videoLength = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"lengthSeconds"]];
    NSArray *videoArtworkArray = youtubePlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
    videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
}

+ (void)getReturnYouTubeDislikesInfo :(NSString *)videoID {
    NSDictionary *returnYouTubeDislikeRequest = [YouTubeExtractor returnYouTubeDislikeRequest:videoID];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    videoViewCount = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"viewCount"]];
    videoLikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"likes"]];
    videoDislikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"dislikes"]];
}

+ (void)getSponsorBlockInfo :(NSString *)videoID {
    sponsorBlockValues = [YouTubeExtractor sponsorBlockRequest:videoID];
}

+ (void)presentPlayer :(NSString *)videoID {
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.videoID = videoID;
    playerViewController.videoURL = videoURL;
    playerViewController.videoLiveOrAgeRestricted = videoLiveOrAgeRestricted;
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
}

@end