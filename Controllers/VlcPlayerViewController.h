#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>

@interface VlcPlayerViewController : UIViewController <VLCMediaPlayerDelegate>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *audioURL;

@end