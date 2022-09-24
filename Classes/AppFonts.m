#import "AppFonts.h"

@implementation AppFonts

+ (UIFont *)mainFont :(CGFloat)fontSize {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 1) {
        return [UIFont systemFontOfSize:fontSize];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 2) {
        return [UIFont systemFontOfSize:fontSize];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 3) {
        return [UIFont fontWithName:@"Minecraft" size:fontSize];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 4) {
        return [UIFont fontWithName:@"Tabitha" size:fontSize];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 5) {
        return [UIFont systemFontOfSize:fontSize];
    }
    return [UIFont systemFontOfSize:fontSize];
}

@end