#import <Foundation/Foundation.h>

@interface YouTubeLoader : NSObject
+ (void)init :(NSString *)videoID;
+ (void)resetLoaderKeys;
+ (void)getTopViewController;
+ (void)getVideoInfo;
+ (void)getReturnYouTubeDislikesInfo :(NSString *)videoID;
+ (void)getSponsorBlockInfo :(NSString *)videoID;
+ (void)presentPlayer :(NSString *)videoID;
@end