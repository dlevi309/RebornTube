#import "SearchViewController.h"

@interface SearchViewController ()
@end

@implementation SearchViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

@end