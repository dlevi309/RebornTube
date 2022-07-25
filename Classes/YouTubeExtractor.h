#import <Foundation/Foundation.h>

@interface YouTubeExtractor : NSObject
+ (NSMutableDictionary *)youtubeiAndroidPlayerRequest :(NSString *)videoID;
+ (NSMutableDictionary *)youtubeiiOSPlayerRequest :(NSString *)videoID;
+ (NSMutableDictionary *)returnYouTubeDislikeRequest :(NSString *)videoID;
@end