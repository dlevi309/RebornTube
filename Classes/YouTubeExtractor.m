#import "YouTubeExtractor.h"

@implementation YouTubeExtractor

+ (NSMutableDictionary *)youtubeiAndroidPlayerRequest :(NSString *)videoID {
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"]];
    [innertubeRequest setHTTPMethod:@"POST"];
    [innertubeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [innertubeRequest setValue:@"CONSENT=YES+" forHTTPHeaderField:@"Cookie"];
    NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"US\",\"clientName\":\"ANDROID\",\"clientVersion\":\"16.20\",\"playbackContext\":{\"contentPlaybackContext\":{\"html5Preference\":\"HTML5_PREF_WANTS\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"videoId\":\"%@\"}", videoID];
    [innertubeRequest setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)youtubeiAndroidSearchRequest :(NSString *)searchQuery {
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/search?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"]];
    [innertubeRequest setHTTPMethod:@"POST"];
    [innertubeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [innertubeRequest setValue:@"CONSENT=YES+" forHTTPHeaderField:@"Cookie"];
    NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"US\",\"clientName\":\"ANDROID\",\"clientVersion\":\"16.20\",\"playbackContext\":{\"contentPlaybackContext\":{\"html5Preference\":\"HTML5_PREF_WANTS\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"query\":\"%@\"}", searchQuery];
    [innertubeRequest setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)youtubeiAndroidTrendingRequest {
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"]];
    [innertubeRequest setHTTPMethod:@"POST"];
    [innertubeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [innertubeRequest setValue:@"CONSENT=YES+" forHTTPHeaderField:@"Cookie"];
    NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"US\",\"clientName\":\"ANDROID\",\"clientVersion\":\"16.20\",\"playbackContext\":{\"contentPlaybackContext\":{\"html5Preference\":\"HTML5_PREF_WANTS\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"browseId\":\"FEtrending\"}"];
    [innertubeRequest setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)youtubeiiOSPlayerRequest :(NSString *)videoID {
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"]];
    [innertubeRequest setHTTPMethod:@"POST"];
    [innertubeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [innertubeRequest setValue:@"CONSENT=YES+" forHTTPHeaderField:@"Cookie"];
    NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"US\",\"clientName\":\"IOS\",\"clientVersion\":\"16.20\",\"playbackContext\":{\"contentPlaybackContext\":{\"html5Preference\":\"HTML5_PREF_WANTS\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"videoId\":\"%@\"}", videoID];
    [innertubeRequest setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)returnYouTubeDislikeRequest :(NSString *)videoID {
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://returnyoutubedislikeapi.com/votes?videoId=%@", videoID]]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSMutableDictionary *)sponsorBlockRequest :(NSString *)videoID {
    NSString *options = @"[%22sponsor%22,%22selfpromo%22,%22interaction%22,%22intro%22,%22outro%22,%22preview%22,%22music_offtopic%22]";
    NSMutableURLRequest *innertubeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@", videoID, options]]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:innertubeRequest returningResponse:nil error:nil];
    NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableDictionary *sponsorBlockValues = [[NSMutableDictionary alloc] init];
    if ([NSJSONSerialization isValidJSONObject:jsonResponse]) {
        for (NSMutableDictionary *jsonDictionary in jsonResponse) {
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"sponsor"]) {
                NSMutableArray *arraySponsorBlockValues = [[NSMutableArray alloc] init];
                [arraySponsorBlockValues removeAllObjects];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][0] floatValue]]];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][1] floatValue]]];
                [sponsorBlockValues setObject:arraySponsorBlockValues forKey:@"sponsor"];
            }
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"selfpromo"]) {
                NSMutableArray *arraySponsorBlockValues = [[NSMutableArray alloc] init];
                [arraySponsorBlockValues removeAllObjects];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][0] floatValue]]];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][1] floatValue]]];
                [sponsorBlockValues setObject:arraySponsorBlockValues forKey:@"selfpromo"];
            }
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"interaction"]) {
                NSMutableArray *arraySponsorBlockValues = [[NSMutableArray alloc] init];
                [arraySponsorBlockValues removeAllObjects];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][0] floatValue]]];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][1] floatValue]]];
                [sponsorBlockValues setObject:arraySponsorBlockValues forKey:@"interaction"];
            }
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"intro"]) {
                NSMutableArray *arraySponsorBlockValues = [[NSMutableArray alloc] init];
                [arraySponsorBlockValues removeAllObjects];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][0] floatValue]]];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][1] floatValue]]];
                [sponsorBlockValues setObject:arraySponsorBlockValues forKey:@"intro"];
            }
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"outro"]) {
                NSMutableArray *arraySponsorBlockValues = [[NSMutableArray alloc] init];
                [arraySponsorBlockValues removeAllObjects];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][0] floatValue]]];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][1] floatValue]]];
                [sponsorBlockValues setObject:arraySponsorBlockValues forKey:@"outro"];
            }
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"preview"]) {
                NSMutableArray *arraySponsorBlockValues = [[NSMutableArray alloc] init];
                [arraySponsorBlockValues removeAllObjects];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][0] floatValue]]];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][1] floatValue]]];
                [sponsorBlockValues setObject:arraySponsorBlockValues forKey:@"preview"];
            }
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"music_offtopic"]) {
                NSMutableArray *arraySponsorBlockValues = [[NSMutableArray alloc] init];
                [arraySponsorBlockValues removeAllObjects];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][0] floatValue]]];
                [arraySponsorBlockValues addObject:[NSNumber numberWithFloat:[[jsonDictionary objectForKey:@"segment"][1] floatValue]]];
                [sponsorBlockValues setObject:arraySponsorBlockValues forKey:@"music_offtopic"];
            }
        }
        return sponsorBlockValues;
    } else {
        return nil;
    }
}

@end