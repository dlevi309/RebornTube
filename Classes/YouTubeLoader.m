#import "YouTubeLoader.h"
#import "YouTubeExtractor.h"

@implementation YouTubeLoader

+ (NSDictionary *)init :(NSString *)videoID {
    NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"IOS":@"16.20":videoID];
    NSString *playabilityStatus = [NSString stringWithFormat:@"%@", youtubePlayerRequest[@"playabilityStatus"][@"status"]];
    if ([playabilityStatus isEqual:@"OK"]) {
        NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];
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