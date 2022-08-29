#import <Foundation/Foundation.h>

@interface YouTubeExtractor : NSObject
+ (NSDictionary *)youtubePlayerRequest :(NSString *)videoID :(NSString *)clientName :(NSString *)clientVersion;
+ (NSDictionary *)youtubeBrowseRequest :(NSString *)clientName :(NSString *)clientVersion :(NSString *)browseId :(NSString *)params;
+ (NSDictionary *)youtubeSearchRequest :(NSString *)clientName :(NSString *)clientVersion :(NSString *)query;
+ (NSDictionary *)returnYouTubeDislikeRequest :(NSString *)videoID;
+ (NSDictionary *)sponsorBlockRequest :(NSString *)videoID;
@end