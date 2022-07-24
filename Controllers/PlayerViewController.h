#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController <AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSURL *videoURL;

@end