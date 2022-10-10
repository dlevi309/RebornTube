// Main

#import "DownloadsViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppFonts.h"

// Interface

@interface DownloadsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
}
- (void)keysSetup;
- (void)navBarSetup;
@end

@implementation DownloadsViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];

	[self keysSetup];
	[self navBarSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
}

- (void)navBarSetup {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = @"RebornTube";
	titleLabel.textColor = [AppColours textColour];
	titleLabel.numberOfLines = 1;
	[titleLabel setFont:[AppFonts mainFont:titleLabel.font.pointSize]];
	titleLabel.adjustsFontSizeToFitWidth = YES;
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];

    self.navigationItem.leftBarButtonItem = titleButton;

	UIImageView *searchImage = [[UIImageView alloc] init];
	searchImage.image = [UIImage systemImageNamed:@"magnifyingglass"];
	searchImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *searchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(search:)];
	searchTap.numberOfTapsRequired = 1;
	[searchImage addGestureRecognizer:searchTap];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView:searchImage];

	UIImageView *settingsImage = [[UIImageView alloc] init];
	settingsImage.image = [UIImage systemImageNamed:@"gearshape"];
	settingsImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *settingsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settings:)];
	settingsTap.numberOfTapsRequired = 1;
	[settingsImage addGestureRecognizer:settingsTap];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsImage];

	self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];
}

@end

@implementation DownloadsViewController (Privates)

// Nav Bar

- (void)search:(UITapGestureRecognizer *)recognizer {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
	[self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings:(UITapGestureRecognizer *)recognizer {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *settingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingsViewControllerView animated:YES completion:nil];
}

@end