#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController <AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *videoLength;
@property (nonatomic, strong) NSString *videoArtwork;
@property (nonatomic, strong) NSString *videoViewCount;
@property (nonatomic, strong) NSString *videoLikes;
@property (nonatomic, strong) NSString *videoDislikes;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSURL *videoURL;

@end