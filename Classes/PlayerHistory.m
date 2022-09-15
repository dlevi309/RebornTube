#import "PlayerHistory.h"

@implementation PlayerHistory

+ (void)init :(NSString *)videoID :(NSString *)playerTime {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playerPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"player.plist"];
    
    NSMutableDictionary *playerDictionary;
    if (![fm fileExistsAtPath:playerPlistFilePath]) {
        playerDictionary = [[NSMutableDictionary alloc] init];
    } else {
        playerDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playerPlistFilePath];
    }

    [playerDictionary setValue:playerTime forKey:videoID];

    [playerDictionary writeToFile:playerPlistFilePath atomically:YES];
}

@end