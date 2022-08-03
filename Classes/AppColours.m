#import "AppColours.h"

@implementation AppColours

+ (UIColor *)mainBackgroundColor {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 2) {
        return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
    }
}

+ (UIColor *)viewBackgroundColor {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 1) {
        return [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 2) {
        return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
}

+ (UIColor *)textColor {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 2) {
        return [UIColor whiteColor];
    } else {
        return [UIColor blackColor];
    }
}

+ (UIColor *)tintColor {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 2) {
        return [UIColor whiteColor];
    } else {
        return [UIColor blackColor];
    }
}

@end