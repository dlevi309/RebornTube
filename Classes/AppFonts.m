#import "AppFonts.h"

@implementation AppFonts

+ (UIFont *)mainFont :(CGFloat)fontSize {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 3) {
        return [UIFont fontWithName:@"Minecraft" size:fontSize];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 4) {
        return [UIFont fontWithName:@"Tabitha" size:fontSize];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"] == 5) {
        return [UIFont fontWithName:@"Times New Roman" size:fontSize];
    }
    return [UIFont systemFontOfSize:fontSize];
}

@end