// Main

#import "HistoryViewController.h"
#import "VideoHistoryViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"
#import "../Settings/SettingsNavigationController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface HistoryViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    UIScrollView *scrollView;
    
    // Other
    NSMutableDictionary *historyIDDictionary;
}
- (void)keysSetup;
- (void)navBarSetup;
@end

@implementation HistoryViewController

- (void)loadView {
	[super loadView];

    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
	[self navBarSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
    scrollView = [[UIScrollView alloc] init];
}

- (void)navBarSetup {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = @"RebornTube";
	titleLabel.textColor = [AppColours textColour];
	titleLabel.numberOfLines = 1;
	titleLabel.adjustsFontSizeToFitWidth = YES;
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];

    self.navigationItem.leftBarButtonItem = titleButton;

	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    
    self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    historyIDDictionary = [NSMutableDictionary new];
    [scrollView removeFromSuperview];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSDictionary *historyDictionary = [NSDictionary dictionaryWithContentsOfFile:historyPlistFilePath];
    NSEnumerator *historyDictionarySorted = [[[historyDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] reverseObjectEnumerator];

    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom);
    
    int viewBounds = 0;
    int dateCount = 1;
    for (NSString *key in historyDictionarySorted) {
        UIView *historyView = [[UIView alloc] init];
        historyView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        historyView.backgroundColor = [AppColours viewBackgroundColour];
        historyView.tag = dateCount;
        historyView.userInteractionEnabled = YES;
        UITapGestureRecognizer *historyViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyTap:)];
        historyViewTap.numberOfTapsRequired = 1;
        [historyView addGestureRecognizer:historyViewTap];

        UILabel *historyDateLabel = [[UILabel alloc] init];
        historyDateLabel.frame = CGRectMake(10, 0, historyView.frame.size.width - 10, historyView.frame.size.height);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:key];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        historyDateLabel.text = [dateFormatter stringFromDate:date];
        historyDateLabel.textColor = [AppColours textColour];
        historyDateLabel.numberOfLines = 1;
        historyDateLabel.adjustsFontSizeToFitWidth = YES;
        [historyView addSubview:historyDateLabel];

        [historyIDDictionary setValue:key forKey:[NSString stringWithFormat:@"%d", dateCount]];
        viewBounds += 42;
        dateCount += 1;

        [scrollView addSubview:historyView];
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

@end

@implementation HistoryViewController (Privates)

// Nav Bar

- (void)search {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];

	[self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	SettingsNavigationController *settingsNavigationController = [[SettingsNavigationController alloc] initWithRootViewController:settingsViewController];
    
	[self presentViewController:settingsNavigationController animated:YES completion:nil];
}

// Other

- (void)historyTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", (int)recognizer.view.tag];
	NSString *historyViewID = [historyIDDictionary valueForKey:historyViewTag];

    VideoHistoryViewController *videoHistoryViewController = [[VideoHistoryViewController alloc] init];
    videoHistoryViewController.entryID = historyViewID;

    [self.navigationController pushViewController:videoHistoryViewController animated:YES];
}

@end