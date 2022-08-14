#import <Foundation/Foundation.h>

@interface YouTubeExtractor : NSObject
+ (NSMutableDictionary *)youtubeiOSPlayerRequest :(NSString *)videoID;
+ (NSMutableDictionary *)youtubeiOSTrendingRequest;
+ (NSMutableDictionary *)youtubeWebSearchRequest :(NSString *)searchQuery;
+ (NSMutableDictionary *)returnYouTubeDislikeRequest :(NSString *)videoID;
+ (NSMutableDictionary *)sponsorBlockRequest :(NSString *)videoID;
@end