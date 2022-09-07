#import <MediaPlayer/MediaPlayer.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <UIKit/UIKit.h>

@interface VLCPlayerViewController : UIViewController <VLCMediaPlayerDelegate>

@property (nonatomic, strong) NSString *videoID;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSURL *streamURL;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *videoAuthor;
@property (nonatomic, strong) NSString *videoLength;
@property (nonatomic, strong) NSURL *videoArtwork;
@property (nonatomic, strong) NSString *videoViewCount;
@property (nonatomic, strong) NSString *videoLikes;
@property (nonatomic, strong) NSString *videoDislikes;
@property (nonatomic, strong) NSDictionary *sponsorBlockValues;

@end