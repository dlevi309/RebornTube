// Main

#import "MainPopupView.h"

// Classes

#import "../Classes/AppColours.h"

// Interface

@interface MainPopupView ()
- (id)_viewControllerForAncestor;
@end

@implementation MainPopupView

- (id)init :(NSString *)message {
    self = [super init];
    if (self) {
        UIViewController *mainViewController = [self _viewControllerForAncestor];        
        UIWindow *boundsWindow = [[[UIApplication sharedApplication] windows] lastObject];

        UIView *mainView = [UIView new];
        mainView.frame = CGRectMake(20, topViewController.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 40, topViewController.view.bounds.size.width - 40, 40);
        mainView.backgroundColor = [AppColours viewBackgroundColour];
        mainView.clipsToBounds = YES;
        mainView.layer.cornerRadius = 5;

        UILabel *messageLabel = [UILabel new];
        messageLabel.frame = CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height);
        messageLabel.text = message;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 1;
        messageLabel.adjustsFontSizeToFitWidth = YES;
        [mainView addSubview:messageLabel];

        [self addSubview:mainView];

        [mainViewController.view addSubview:self];
        [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer *timer) {
            [self removeFromSuperview];
        }];
    }
    return self;
}

@end