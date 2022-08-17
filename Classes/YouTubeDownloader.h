#import <Foundation/Foundation.h>

@interface YouTubeDownloader : NSObject
+ (void)init :(NSString *)videoID;
+ (void)videoDownloader :(NSURL *)videoURL :(NSURL *)audioURL;
+ (void)audioDownloader :(NSURL *)audioURL;
@end