// Main

#import "NoInternetViewController.h"

// Classes

#import "../Classes/AppColours.h"

// Interface

@interface NoInternetViewController ()
@end

@implementation NoInternetViewController

- (void)loadView {
	[super loadView];

	self.title = @"Error";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
    
    UILabel *noInternetLabel = [[UILabel alloc] init];
    noInternetLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 50);
	noInternetLabel.text = @"No Connection";
	noInternetLabel.textColor = [AppColours textColour];
	noInternetLabel.numberOfLines = 1;
    noInternetLabel.textAlignment = NSTextAlignmentCenter;
	noInternetLabel.adjustsFontSizeToFitWidth = true;
	noInternetLabel.adjustsFontForContentSizeCategory = false;

    [self.view addSubview:noInternetLabel];
}

@end