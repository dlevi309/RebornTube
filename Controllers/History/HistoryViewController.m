// Main

#import "HistoryViewController.h"
#import "VideoHistoryViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface HistoryViewController ()
{
    // Keys
	UIWindow *boundsWindow;
    
    // Other
    NSMutableDictionary *historyIDDictionary;
}
- (void)keysSetup;
@end

@implementation HistoryViewController

- (void)loadView {
	[super loadView];
    [self keysSetup];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    historyIDDictionary = [NSMutableDictionary new];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSMutableDictionary *historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - 50);
    
    int viewBounds = 0;
    int dateCount = 1;
    for (NSString *key in historyDictionary) {
        UIView *historyView = [[UIView alloc] init];
        historyView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        historyView.backgroundColor = [AppColours viewBackgroundColour];
        historyView.tag = dateCount;
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
        historyDateLabel.adjustsFontSizeToFitWidth = true;
        historyDateLabel.adjustsFontForContentSizeCategory = false;
        [historyView addSubview:historyDateLabel];

        [historyIDDictionary setValue:key forKey:[NSString stringWithFormat:@"%d", dateCount]];
        viewBounds += 42;
        dateCount += 1;

        [scrollView addSubview:historyView];
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation HistoryViewController (Privates)

- (void)historyTap:(UITapGestureRecognizer *)recognizer {
    NSString *historyViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *historyViewID = [historyIDDictionary valueForKey:historyViewTag];

    VideoHistoryViewController *historyVideosViewController = [[VideoHistoryViewController alloc] init];
    historyVideosViewController.historyViewID = historyViewID;

    [self.navigationController pushViewController:historyVideosViewController animated:YES];
}

@end