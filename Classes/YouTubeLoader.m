#import "YouTubeLoader.h"
#import "YouTubeExtractor.h"

@implementation YouTubeLoader

+ (NSDictionary *)init :(NSString *)videoID {
    NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"IOS":@"16.20":videoID];
    NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
    if ([playabilityStatus isEqual:@"OK"]) {
        NSDictionary *innertubeAdaptiveFormats = youtubePlayerRequest[@"streamingData"][@"adaptiveFormats"];
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

        NSURL *audioURL;
        if (audioHigh != nil) {
            audioURL = audioHigh;
        } else if (audioMedium != nil) {
            audioURL = audioMedium;
        } else if (audioLow != nil) {
            audioURL = audioLow;
        }

        NSURL *streamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
        NSString *videoLive = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"isLive"]];
        NSString *videoTitle = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"title"]];
        NSString *videoAuthor = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"author"]];
        NSString *videoLength = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"videoDetails"][@"lengthSeconds"]];
        NSArray *videoArtworkArray = youtubePlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
        NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];

        NSDictionary *returnYouTubeDislikeRequest = [YouTubeExtractor returnYouTubeDislikeRequest:videoID];
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *videoViewCount = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"viewCount"]];
        NSString *videoLikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"likes"]];
        NSString *videoDislikes = [formatter stringFromNumber:returnYouTubeDislikeRequest[@"dislikes"]];

        NSDictionary *sponsorBlockValues = [YouTubeExtractor sponsorBlockRequest:videoID];

        NSMutableDictionary *loaderDictionary = [[NSMutableDictionary alloc] init];
        [loaderDictionary setValue:videoID forKey:@"videoID"];
        [loaderDictionary setValue:videoURL forKey:@"videoURL"];
        [loaderDictionary setValue:audioURL forKey:@"audioURL"];
        [loaderDictionary setValue:streamURL forKey:@"streamURL"];
        [loaderDictionary setValue:videoLive forKey:@"videoLive"];
        [loaderDictionary setValue:videoTitle forKey:@"videoTitle"];
        [loaderDictionary setValue:videoAuthor forKey:@"videoAuthor"];
        [loaderDictionary setValue:videoLength forKey:@"videoLength"];
        [loaderDictionary setValue:videoArtwork forKey:@"videoArtwork"];
        [loaderDictionary setValue:videoViewCount forKey:@"videoViewCount"];
        [loaderDictionary setValue:videoLikes forKey:@"videoLikes"];
        [loaderDictionary setValue:videoDislikes forKey:@"videoDislikes"];
        [loaderDictionary setValue:sponsorBlockValues forKey:@"sponsorBlockValues"];
        return [loaderDictionary copy];
    }
    return nil;
}

@end