#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController <AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) NSString *videoID;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BOOL videoLiveOrAgeRestricted;
@property (nonatomic, assign) BOOL videoLive;
@property (nonatomic, assign) BOOL videoAgeRestricted;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *videoAuthor;
@property (nonatomic, strong) NSString *videoLength;
@property (nonatomic, strong) NSURL *videoArtwork;
@property (nonatomic, strong) NSString *videoViewCount;
@property (nonatomic, strong) NSString *videoLikes;
@property (nonatomic, strong) NSString *videoDislikes;
@property (nonatomic, strong) NSDictionary *sponsorBlockValues;

@end