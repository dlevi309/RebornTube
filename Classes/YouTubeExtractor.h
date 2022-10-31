#import <Foundation/Foundation.h>

@interface YouTubeExtractor : NSObject
+ (NSDictionary *)youtubePlayerRequest :(NSString *)clientName :(NSString *)clientVersion :(NSString *)videoID;
+ (NSDictionary *)youtubeBrowseRequest :(NSString *)clientName :(NSString *)clientVersion :(NSString *)browseId :(NSString *)params;
+ (NSDictionary *)youtubeSearchRequest :(NSString *)clientName :(NSString *)clientVersion :(NSString *)query;
+ (NSDictionary *)returnYouTubeDislikeRequest :(NSString *)videoID;
@end