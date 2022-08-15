#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController <AVPictureInPictureControllerDelegate>

// Main Info
@property (nonatomic, strong) NSString *videoID;

// Player Info
@property (nonatomic, strong) NSURL *videoStream;
@property (nonatomic, strong) NSURL *videoURL;

// Other Info
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *videoAuthor;
@property (nonatomic, strong) NSString *videoLength;
@property (nonatomic, strong) NSURL *videoArtwork;
@property (nonatomic, strong) NSString *videoViewCount;
@property (nonatomic, strong) NSString *videoLikes;
@property (nonatomic, strong) NSString *videoDislikes;
@property (nonatomic, strong) NSMutableDictionary *sponsorBlockValues;

@end