// Main

#import "MainPopupView.h"

// Classes

#import "../Classes/AppColours.h"

// Interface

@interface MainPopupView ()
@end

@implementation MainPopupView

- (id)initWithFrame:(CGRect)frame message:(NSString *)message {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *mainView = [UIView new];
        mainView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        mainView.backgroundColor = [AppColours viewBackgroundColour];
        mainView.clipsToBounds = YES;
        mainView.layer.cornerRadius = 5;

        UILabel *messageLabel = [UILabel new];
        messageLabel.frame = CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height);
        messageLabel.text = message;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 2;
        messageLabel.adjustsFontSizeToFitWidth = YES;
        [mainView addSubview:messageLabel];

        [self addSubview:mainView];

        UIViewController *topViewController = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        while (true) {
            if (topViewController.presentedViewController) {
                topViewController = topViewController.presentedViewController;
            } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)topViewController;
                topViewController = nav.topViewController;
            } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tab = (UITabBarController *)topViewController;
                topViewController = tab.selectedViewController;
            } else {
                break;
            }
        }

        [topViewController.view addSubview:self];
        [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer *timer) {
            [self removeFromSuperview];
        }];
    }
    return self;
}

@end