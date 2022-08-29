#import <Foundation/Foundation.h>

@interface YouTubeLoader : NSObject
+ (void)init :(NSString *)videoID;
+ (void)getTopViewController;
+ (void)getVideoUrl;
+ (void)getVideoInfo;
+ (void)getReturnYouTubeDislikesInfo :(NSString *)videoID;
+ (void)getSponsorBlockInfo :(NSString *)videoID;
+ (void)presentPlayerOptions :(NSString *)videoID;
+ (void)presentAVPlayer :(NSString *)videoID;
+ (void)presentVLCPlayer :(NSString *)videoID;
@end