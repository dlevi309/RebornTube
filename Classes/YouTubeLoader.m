#import "YouTubeLoader.h"
#import "EUCheck.h"
#import "YouTubeExtractor.h"
#import "../Controllers/Player/PlayerViewController.h"
#import "../Controllers/Player/VLCPlayerViewController.h"
#import "../Controllers/Playlists/AddToPlaylistsViewController.h"

// Top View Controller
UIViewController *topViewController;

// Request Response
NSDictionary *youtubePlayerRequest;

// Video Info
NSURL *videoURL;
int playbackType;
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
    [self getTopViewController];

    youtubePlayerRequest = [YouTubeExtractor youtubeAndroidPlayerRequest:videoID];
    NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
    BOOL isLive = youtubePlayerRequest[@"videoDetails"][@"isLive"];

    if (isLive != true && [playabilityStatus isEqual:@"OK"]) {
        [self getVideoUrl];
        playbackType = 0;
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentPlayerOptions:videoID];
        
    } else if (isLive == true && [playabilityStatus isEqual:@"OK"]) {
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
        playbackType = 1;
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentPlayerOptions:videoID];
    } else if (isLive != true && ![playabilityStatus isEqual:@"OK"]) {
        BOOL isLocatedInEU = [EUCheck isLocatedInEU];
        if (isLocatedInEU == 1) {
            UIAlertController *alertEUCheck = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Due to EU laws, I can't allow for age restricted video playback without id and I am not implementing that due to privacy issues, sorry" preferredStyle:UIAlertControllerStyleAlert];

            [alertEUCheck addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];

            [topViewController presentViewController:alertEUCheck animated:YES completion:nil];
        } else {
            youtubePlayerRequest = [YouTubeExtractor youtubeTVOSEmbedPlayerRequest:videoID];
            [self getVideoUrl];
            playbackType = 2;
            [self getVideoInfo];
            [self getReturnYouTubeDislikesInfo:videoID];
            [self getSponsorBlockInfo:videoID];
            [self presentPlayerOptions:videoID];
        }
    }
}

+ (void)getTopViewController {
    topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
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

+ (void)presentPlayerOptions :(NSString *)videoID {
    UIAlertController *alertPlayerOptions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"AVPlayer (720p Max)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self presentAVPlayer:videoID];
    }]];

    [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"VLC (4K Max, Experimental)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self presentVLCPlayer:videoID];
    }]];

    [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertPlayerOptions setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertPlayerOptions popoverPresentationController];
    popPresenter.sourceView = topViewController.view;
    popPresenter.sourceRect = topViewController.view.bounds;
    popPresenter.permittedArrowDirections = 0;

    [topViewController presentViewController:alertPlayerOptions animated:YES completion:nil];
}

+ (void)presentAVPlayer :(NSString *)videoID {
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.videoID = videoID;
    playerViewController.videoURL = videoURL;
    playerViewController.playbackType = playbackType;
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

+ (void)presentVLCPlayer :(NSString *)videoID {
    VLCPlayerViewController *playerViewController = [[VLCPlayerViewController alloc] init];
    playerViewController.videoID = videoID;
    playerViewController.videoURL = videoURL;
    playerViewController.playbackType = playbackType;
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