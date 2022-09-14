#import "YouTubeLoader.h"
#import "YouTubeExtractor.h"
#import "../Views/MainPopupView.h"
#import "../Controllers/Player/PlayerViewController.h"

// Top View Controller
UIViewController *topViewController;

// Request Response
NSDictionary *youtubePlayerRequest;

// Video Info
NSURL *videoURL;
BOOL videoLive;
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

    youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"IOS":@"16.20":videoID];
    NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
    if ([playabilityStatus isEqual:@"OK"]) {
        BOOL isLive = youtubePlayerRequest[@"videoDetails"][@"isLive"];
        if (isLive) {
            videoLive = YES;
        } else if (!isLive) {
            videoLive = NO;
        }
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentPlayer:videoID];
    } else {
        (void)[[MainPopupView alloc] init:@"Video Unsupported"];
    }
}

+ (void)resetLoaderKeys {
    // Top View Controller
    topViewController = nil;

    // Request Response
    youtubePlayerRequest = nil;

    // Video Info
    videoURL = nil;
    videoLive = NO;
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
    playerViewController.videoLive = videoLive;
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