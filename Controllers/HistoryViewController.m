#import "HistoryViewController.h"
#import "RootViewController.h"

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