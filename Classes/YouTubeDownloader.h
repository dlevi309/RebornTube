#import <Foundation/Foundation.h>

@interface YouTubeDownloader : NSObject
+ (void)init :(NSString *)videoID;
+ (void)videoDownloader :(NSString *)videoURL :(NSString *)audioURL;
+ (void)audioDownloader :(NSString *)audioURL;
@end