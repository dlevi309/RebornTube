#import "HistoryViewController.h"
#import "RootViewController.h"
#import "../Classes/YouTubeExtractor.h"

@interface HistoryViewController ()
@end

@implementation HistoryViewController

- (void)loadView {
	[super loadView];

	self.title = @"History";
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
    
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 50, self.view.bounds.size.width, 50)];
    tabBar.delegate = self;

    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"History" image:nil tag:1];
    [tabBarItems addObject:tabBarItem1];
    [tabBarItems addObject:tabBarItem2];

    tabBar.items = tabBarItems;
    tabBar.selectedItem = [tabBarItems objectAtIndex:1];
    [self.view addSubview:tabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
    NSMutableDictionary *historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];

    UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - 50);
    
    int trueBounds = 0;
    for (NSString *key in historyDictionary) {
        int viewBounds = 0;
        NSMutableArray *historyArray = [historyDictionary objectForKey:key];
        for (NSString *videoID in historyArray) {
            NSMutableDictionary *youtubeiAndroidPlayerRequest = [YouTubeExtractor youtubeiAndroidPlayerRequest:videoID];
            NSString *videoTitle = [NSString stringWithFormat:@"%@", youtubeiAndroidPlayerRequest[@"videoDetails"][@"title"]];

            UIView *historyView = [[UIView alloc] init];
			historyView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 80);
			historyView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];

            UILabel *videoTitleLabel = [[UILabel alloc] init];
			videoTitleLabel.frame = CGRectMake(85, 0, historyView.frame.size.width - 85, historyView.frame.size.height);
			videoTitleLabel.text = videoTitle;
			videoTitleLabel.textColor = [UIColor whiteColor];
			videoTitleLabel.numberOfLines = 2;
			videoTitleLabel.adjustsFontSizeToFitWidth = true;
			videoTitleLabel.adjustsFontForContentSizeCategory = false;
			[historyView addSubview:videoTitleLabel];

            viewBounds += 82;
            trueBounds += 82;
			[scrollView addSubview:historyView];
        }
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, trueBounds);
	[self.view addSubview:scrollView];
}

@end

@implementation HistoryViewController (Privates)

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    int selectedTag = tabBar.selectedItem.tag;
    if (selectedTag == 0) {
        RootViewController *rootViewController = [[RootViewController alloc] init];

        UINavigationController *rootViewControllerView = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        rootViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:rootViewControllerView animated:NO completion:nil];
    }
}

@end