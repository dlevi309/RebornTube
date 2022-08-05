#import "AppColours.h"

@implementation AppColours

+ (UIColor *)mainBackgroundColour {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 1) {
        return [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 2 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 3) {
        return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    } else {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            return [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
        } else {
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        }
    }
}

+ (UIColor *)viewBackgroundColour {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 1) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 2) {
        return [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 3) {
        return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    } else {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        } else {
            return [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
        }
    }
}

+ (UIColor *)textColour {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 1) {
        return [UIColor blackColor];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 2 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"] == 3) {
        return [UIColor whiteColor];
    } else {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            return [UIColor blackColor];
        } else {
            return [UIColor whiteColor];
        }
    }
}

@end