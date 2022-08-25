#import <Foundation/Foundation.h>

@interface YouTubeExtractor : NSObject
+ (NSMutableDictionary *)youtubeAndroidPlayerRequest :(NSString *)videoID;
+ (NSMutableDictionary *)youtubeTVOSEmbedPlayerRequest :(NSString *)videoID;
+ (NSMutableDictionary *)youtubeAndroidBrowseRequest :(NSString *)browseId :(NSString *)browseParams;
+ (NSMutableDictionary *)youtubeWebSearchRequest :(NSString *)searchQuery;
+ (NSMutableDictionary *)returnYouTubeDislikeRequest :(NSString *)videoID;
+ (NSMutableDictionary *)sponsorBlockRequest :(NSString *)videoID;
@end