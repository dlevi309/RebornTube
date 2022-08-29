#import "YouTubeExtractor.h"

@implementation YouTubeExtractor

+ (NSMutableDictionary *)youtubeAndroidPlayerRequest :(NSString *)videoID {
    NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"]];
    [innertubeRequest setHTTPMethod:@"POST"];
    [innertubeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [innertubeRequest setValue:@"CONSENT=YES+" forHTTPHeaderField:@"Cookie"];
    NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"%@\",\"clientName\":\"ANDROID\",\"clientVersion\":\"16.20\",\"playbackContext\":{\"contentPlaybackContext\":{\"signatureTimestamp\":\"sts\",\"html5Preference\":\"HTML5_PREF_WANTS\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"videoId\":\"%@\"}", countryCode, videoID];
    [innertubeRequest setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)youtubeAndroidBrowseRequest :(NSString *)browseId :(NSString *)browseParams {
    NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"]];
    [innertubeRequest setHTTPMethod:@"POST"];
    [innertubeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [innertubeRequest setValue:@"CONSENT=YES+" forHTTPHeaderField:@"Cookie"];
    NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"%@\",\"clientName\":\"ANDROID\",\"clientVersion\":\"16.20\",\"playbackContext\":{\"contentPlaybackContext\":{\"signatureTimestamp\":\"sts\",\"html5Preference\":\"HTML5_PREF_WANTS\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"browseId\":\"%@\",\"params\":\"%@\"}", countryCode, browseId, browseParams];
    [innertubeRequest setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)youtubeWebSearchRequest :(NSString *)searchQuery {
    NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/search?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"]];
    [innertubeRequest setHTTPMethod:@"POST"];
    [innertubeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [innertubeRequest setValue:@"CONSENT=YES+" forHTTPHeaderField:@"Cookie"];
    NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"%@\",\"clientName\":\"WEB\",\"clientVersion\":\"2.20210401.08.00\",\"playbackContext\":{\"contentPlaybackContext\":{\"signatureTimestamp\":\"sts\",\"html5Preference\":\"HTML5_PREF_WANTS\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"query\":\"%@\"}", countryCode, searchQuery];
    [innertubeRequest setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)returnYouTubeDislikeRequest :(NSString *)videoID {
    NSURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://returnyoutubedislikeapi.com/votes?videoId=%@", videoID]]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)sponsorBlockRequest :(NSString *)videoID {
    NSString *options = @"[%22sponsor%22,%22selfpromo%22,%22interaction%22,%22intro%22,%22outro%22,%22preview%22,%22music_offtopic%22]";
    NSURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@", videoID, options]]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([NSJSONSerialization isValidJSONObject:jsonResponse]) {
        return jsonResponse;
    } else {
        return nil;
    }
}

@end