#import "EUCheck.h"

@implementation EUCheck

+ (BOOL)isLocatedInEU {
    NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];

    NSArray *euCountryCodes = @[@"AT", @"BE", @"BG", @"HR", @"CY", @"CZ", @"DK", @"EE", @"FI", @"FR", @"DE", @"GR", @"HU", @"IE", @"IT", @"LV", @"LT", @"LU", @"MT", @"NL", @"PL", @"PT", @"RO", @"SK", @"SI", @"ES", @"SE", @"GB"];
    for (NSString *euCountryCode in euCountryCodes) {
        if ([euCountryCode isEqual:countryCode]) {
            return YES;
        }
    }
    return NO;
}

@end