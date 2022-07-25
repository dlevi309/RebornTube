#import "SearchViewController.h"
#import "../Classes/YouTubeExtractor.h"

@interface SearchViewController ()
{
	UITextField *searchTextField;
}
- (void)searchRequest;
@end

@implementation SearchViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];

	searchTextField = [[UITextField alloc] init];
	searchTextField.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 60);
	searchTextField.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	searchTextField.placeholder = @"Search Here";
	[searchTextField addTarget:self action:@selector(searchRequest) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.view addSubview:searchTextField];
}

@end

@implementation SearchViewController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchRequest {
	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
	NSMutableDictionary *youtubeiAndroidSearchRequest = [YouTubeExtractor youtubeiAndroidSearchRequest:[searchTextField text]];
    NSArray *searchContents = youtubeiAndroidSearchRequest[@"contents"][@"sectionListRenderer"][@"contents"][0][@"itemSectionRenderer"][@"contents"];
	UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + searchTextField.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - self.navigationController.navigationBar.frame.size.height - searchTextField.frame.size.height);
	
	int viewBounds = 0;
	for (int i = 1 ; i <= 50 ; i++) {
		@try {
			UIImageView *videoImage = [[UIImageView alloc] init];
			videoImage.frame = CGRectMake(0, viewBounds, 80, 80);
			videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"thumbnail"][@"thumbnails"][0][@"url"]]]]];
			[scrollView addSubview:videoImage];

			UILabel *videoTitleLabel = [[UILabel alloc] init];
			videoTitleLabel.frame = CGRectMake(80, viewBounds, self.view.bounds.size.width - 80, 80);
			videoTitleLabel.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
			videoTitleLabel.text = searchContents[i][@"compactVideoRenderer"][@"title"][@"runs"][0][@"text"];
			videoTitleLabel.textColor = [UIColor whiteColor];
			videoTitleLabel.numberOfLines = 2;
			videoTitleLabel.adjustsFontSizeToFitWidth = true;
			videoTitleLabel.adjustsFontForContentSizeCategory = false;
			[scrollView addSubview:videoTitleLabel];
			viewBounds += 82;
		}
        @catch (NSException *exception) {
        }
	}

	scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

@end