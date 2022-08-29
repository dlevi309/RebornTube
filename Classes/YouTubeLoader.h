#import <Foundation/Foundation.h>

@interface YouTubeLoader : NSObject
+ (void)init :(NSString *)videoID;
+ (void)getTopViewController;
+ (void)presentPlayerOptions :(NSString *)videoID;
+ (void)runAVPlayerSteps :(NSString *)videoID;
+ (void)runVLCPlayerSteps :(NSString *)videoID;
+ (void)getAVPlayerVideoUrl;
+ (void)getVLCPlayerUrls;
+ (void)getVideoInfo;
+ (void)getReturnYouTubeDislikesInfo :(NSString *)videoID;
+ (void)getSponsorBlockInfo :(NSString *)videoID;
+ (void)presentAVPlayer :(NSString *)videoID;
+ (void)presentVLCPlayer :(NSString *)videoID;
@end