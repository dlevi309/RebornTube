#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileVLCKit/MobileVLCKit.h>

@interface VlcPlayerViewController : UIViewController <VLCMediaPlayerDelegate>

@property (nonatomic, strong) NSString *videoID;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSURL *videoArtwork;
@property (nonatomic, strong) NSString *videoViewCount;
@property (nonatomic, strong) NSString *videoLikes;
@property (nonatomic, strong) NSString *videoDislikes;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSMutableDictionary *sponsorBlockValues;

@end