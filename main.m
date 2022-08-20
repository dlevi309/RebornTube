#import "main.h"
#import "Classes/AppDelegate.h"

@implementation RebornTube

- (UIContentSizeCategory)preferredContentSizeCategory {
    return UIContentSizeCategoryLarge;
}

@end

int main(int argc, char *argv[]) {
	@autoreleasepool {
		return UIApplicationMain(argc, argv, NSStringFromClass([RebornTube class]), NSStringFromClass([AppDelegate class]));
	}
}