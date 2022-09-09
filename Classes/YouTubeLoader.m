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
NSURL *audioURL;
NSURL *streamURL;
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
    [self presentPlayerOptions:videoID];
}

+ (void)resetLoaderKeys {
    // Top View Controller
    topViewController = nil;

    // Request Response
    youtubePlayerRequest = nil;

    // Video Info
    videoURL = nil;
    audioURL = nil;
    streamURL = nil;
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

+ (void)presentPlayerOptions :(NSString *)videoID {
    UIAlertController *alertPlayerOptions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"AVPlayer" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self runAVPlayerSteps:videoID];
    }]];

    [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"VLC Player (Experimental)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self runVLCPlayerSteps:videoID];
    }]];

    [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [topViewController presentViewController:alertPlayerOptions animated:YES completion:nil];
}

+ (void)runAVPlayerSteps :(NSString *)videoID {
    youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"ANDROID":@"16.20":videoID];
    BOOL isLive = youtubePlayerRequest[@"videoDetails"][@"isLive"];
    NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
    if (isLive == true && [playabilityStatus isEqual:@"OK"]) {
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentAVPlayer:videoID];
    } else if (isLive != true && [playabilityStatus isEqual:@"OK"]) {
        [self getAVPlayerVideoUrl];
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentAVPlayer:videoID];
    }
}

+ (void)runVLCPlayerSteps :(NSString *)videoID {
    youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"ANDROID":@"16.20":videoID];
    BOOL isLive = youtubePlayerRequest[@"videoDetails"][@"isLive"];
    NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
    if (isLive == true && [playabilityStatus isEqual:@"OK"]) {
        streamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentVLCPlayer:videoID];
    } else if (isLive != true && [playabilityStatus isEqual:@"OK"]) {
        [self getVLCPlayerUrls];
        [self getVideoInfo];
        [self getReturnYouTubeDislikesInfo:videoID];
        [self getSponsorBlockInfo:videoID];
        [self presentVLCPlayer:videoID];
    }
}

+ (void)getAVPlayerVideoUrl {
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

+ (void)getVLCPlayerUrls {
    NSDictionary *innertubeAdaptiveFormats = youtubePlayerRequest[@"streamingData"][@"adaptiveFormats"];
    NSURL *webm2160p;
    NSURL *webm1440p;
    NSURL *webm1080p;
    NSURL *webm720p;
    NSURL *webm480p;
    NSURL *webm360p;
    NSURL *webm240p;
    NSURL *webmHigh;
    NSURL *webmMedium;
    NSURL *webmLow;
    NSURL *mp42160p;
    NSURL *mp41440p;
    NSURL *mp41080p;
    NSURL *mp4720p;
    NSURL *mp4480p;
    NSURL *mp4360p;
    NSURL *mp4240p;
    NSURL *mp4High;
    NSURL *mp4Medium;
    NSURL *mp4Low;
    for (NSDictionary *format in innertubeAdaptiveFormats) {
        if ([[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"2160"] || [[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd2160"]) {
            if (webm2160p == nil) {
                webm2160p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1440"] || [[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1440"]) {
            if (webm1440p == nil) {
                webm1440p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1080"] || [[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1080"]) {
            if (webm1080p == nil) {
                webm1080p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"720"] || [[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd720"]) {
            if (webm720p == nil) {
                webm720p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"480"] || [[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"480p"]) {
            if (webm480p == nil) {
                webm480p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"360"] || [[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"360p"]) {
            if (webm360p == nil) {
                webm360p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"240"] || [[format objectForKey:@"mimeType"] containsString:@"video/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"240p"]) {
            if (webm240p == nil) {
                webm240p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_HIGH"]) {
            if (webmHigh == nil) {
                webmHigh = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_MEDIUM"]) {
            if (webmMedium == nil) {
                webmMedium = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/webm"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_LOW"]) {
            if (webmLow == nil) {
                webmLow = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"2160"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd2160"]) {
            if (mp42160p == nil) {
                mp42160p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1440"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1440"]) {
            if (mp41440p == nil) {
                mp41440p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1080"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1080"]) {
            if (mp41080p == nil) {
                mp41080p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"720"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd720"]) {
            if (mp4720p == nil) {
                mp4720p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"480"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"480p"]) {
            if (mp4480p == nil) {
                mp4480p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"360"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"360p"]) {
            if (mp4360p == nil) {
                mp4360p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"240"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"240p"]) {
            if (mp4240p == nil) {
                mp4240p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_HIGH"]) {
            if (mp4High == nil) {
                mp4High = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_MEDIUM"]) {
            if (mp4Medium == nil) {
                mp4Medium = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_LOW"]) {
            if (mp4Low == nil) {
                mp4Low = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        }
    }

    NSURL *webmVideoURL;
    if (webm2160p != nil) {
        webmVideoURL = webm2160p;
    } else if (webm1440p != nil) {
        webmVideoURL = webm1440p;
    } else if (webm1080p != nil) {
        webmVideoURL = webm1080p;
    } else if (webm720p != nil) {
        webmVideoURL = webm720p;
    } else if (webm480p != nil) {
        webmVideoURL = webm480p;
    } else if (webm360p != nil) {
        webmVideoURL = webm360p;
    } else if (webm240p != nil) {
        webmVideoURL = webm240p;
    }

    NSURL *mp4VideoURL;
    if (mp42160p != nil) {
        mp4VideoURL = mp42160p;
    } else if (mp41440p != nil) {
        mp4VideoURL = mp41440p;
    } else if (mp41080p != nil) {
        mp4VideoURL = mp41080p;
    } else if (mp4720p != nil) {
        mp4VideoURL = mp4720p;
    } else if (mp4480p != nil) {
        mp4VideoURL = mp4480p;
    } else if (mp4360p != nil) {
        mp4VideoURL = mp4360p;
    } else if (mp4240p != nil) {
        mp4VideoURL = mp4240p;
    }

    NSURL *webmAudioURL;
    if (webmHigh != nil) {
        webmAudioURL = webmHigh;
    } else if (webmMedium != nil) {
        webmAudioURL = webmMedium;
    } else if (webmLow != nil) {
        webmAudioURL = webmLow;
    }

    NSURL *mp4AudioURL;
    if (mp4High != nil) {
        mp4AudioURL = mp4High;
    } else if (mp4Medium != nil) {
        mp4AudioURL = mp4Medium;
    } else if (mp4Low != nil) {
        mp4AudioURL = mp4Low;
    }

    if (webmVideoURL != nil) {
        videoURL = webmVideoURL;
    } else if (mp4VideoURL != nil) {
        videoURL = mp4VideoURL;
    }

    if (webmAudioURL != nil) {
        audioURL = webmAudioURL;
    } else if (mp4AudioURL != nil) {
        audioURL = mp4AudioURL;
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

+ (void)presentAVPlayer :(NSString *)videoID {
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.videoID = videoID;
    playerViewController.videoURL = videoURL;
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
    playerViewController.audioURL = audioURL;
    playerViewController.streamURL = streamURL;
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