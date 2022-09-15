#import "YouTubeDownloader.h"
#import "YouTubeExtractor.h"
#import "../AFNetworking/AFNetworking.h"
#import <ffmpegkit/FFmpegKit.h>
#import <Photos/Photos.h>

@implementation YouTubeDownloader

+ (void)init :(NSString *)videoID {
    UIViewController *topViewController = [[[[UIApplication sharedApplication] windows] lastObject] rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topViewController;
            topViewController = nav.topViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }

    NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"ANDROID":@"16.20":videoID];
    NSDictionary *innertubeAdaptiveFormats = youtubePlayerRequest[@"streamingData"][@"adaptiveFormats"];
    NSURL *video2160p;
    NSURL *video1440p;
    NSURL *video1080p;
    NSURL *video720p;
    NSURL *video480p;
    NSURL *video360p;
    NSURL *video240p;
    NSURL *audioHigh;
    NSURL *audioMedium;
    NSURL *audioLow;
    for (NSDictionary *format in innertubeAdaptiveFormats) {
        if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"2160"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd2160"]) {
            if (video2160p == nil) {
                video2160p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1440"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1440"]) {
            if (video1440p == nil) {
                video1440p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"1080"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd1080"]) {
            if (video1080p == nil) {
                video1080p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"720"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"quality"]] isEqual:@"hd720"]) {
            if (video720p == nil) {
                video720p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"480"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"480p"]) {
            if (video480p == nil) {
                video480p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"360"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"360p"]) {
            if (video360p == nil) {
                video360p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"height"]] isEqual:@"240"] || [[format objectForKey:@"mimeType"] containsString:@"video/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"qualityLabel"]] isEqual:@"240p"]) {
            if (video240p == nil) {
                video240p = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_HIGH"]) {
            if (audioHigh == nil) {
                audioHigh = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_MEDIUM"]) {
            if (audioMedium == nil) {
                audioMedium = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        } else if ([[format objectForKey:@"mimeType"] containsString:@"audio/mp4"] & [[NSString stringWithFormat:@"%@", [format objectForKey:@"audioQuality"]] isEqual:@"AUDIO_QUALITY_LOW"]) {
            if (audioLow == nil) {
                audioLow = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [format objectForKey:@"url"]]];
            }
        }
    }

    NSURL *audioURL;
    if (audioHigh != nil) {
        audioURL = audioHigh;
    } else if (audioMedium != nil) {
        audioURL = audioMedium;
    } else if (audioLow != nil) {
        audioURL = audioLow;
    }

    UIAlertController *alertQualitySelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if (video240p != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"240p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self videoDownloader:video240p:audioURL];
        }]];
    }
    if (video360p != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"360p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self videoDownloader:video360p:audioURL];
        }]];
    }
    if (video480p != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"480p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self videoDownloader:video480p:audioURL];
        }]];
    }
    if (video720p != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"720p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self videoDownloader:video720p:audioURL];
        }]];
    }
    if (video1080p != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"1080p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self videoDownloader:video1080p:audioURL];
        }]];
    }
    if (video1440p != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"1440p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self videoDownloader:video1440p:audioURL];
        }]];
    }
    if (video2160p != nil) {
        [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"2160p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self videoDownloader:video2160p:audioURL];
        }]];
    }

    [alertQualitySelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertQualitySelector setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertQualitySelector popoverPresentationController];
    popPresenter.sourceView = topViewController.view;
    popPresenter.sourceRect = topViewController.view.bounds;
    popPresenter.permittedArrowDirections = 0;

    [topViewController presentViewController:alertQualitySelector animated:YES completion:nil];
}

+ (void)videoDownloader :(NSURL *)videoURL :(NSURL *)audioURL {
    UIViewController *topViewController = [[[[UIApplication sharedApplication] windows] lastObject] rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topViewController;
            topViewController = nav.topViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }

    UIAlertController *alertDownloading = [UIAlertController alertControllerWithTitle:@"Notice" message:[NSString stringWithFormat:@"Video (Part 1/2) Is Downloading \n\nProgress: 0.00%% \n\nDon't Exit The App"] preferredStyle:UIAlertControllerStyleAlert];

    [topViewController presentViewController:alertDownloading animated:YES completion:^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:videoURL];

        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float downloadPercent = downloadProgress.fractionCompleted * 100;
                alertDownloading.message = [NSString stringWithFormat:@"Video (Part 1/2) Is Downloading \n\nProgress: %.02f%% \n\nDon't Exit The App", downloadPercent];
            });
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            [[NSFileManager defaultManager] moveItemAtPath:[filePath path] toPath:[NSString stringWithFormat:@"%@/video.mp4", documentsDirectory] error:nil];
            [alertDownloading dismissViewControllerAnimated:YES completion:^{
                [self audioDownloader:audioURL];
            }];
        }];
        [downloadTask resume];
    }];
}

+ (void)audioDownloader :(NSURL *)audioURL {
    UIViewController *topViewController = [[[[UIApplication sharedApplication] windows] lastObject] rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topViewController;
            topViewController = nav.topViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }

    UIAlertController *alertDownloading = [UIAlertController alertControllerWithTitle:@"Notice" message:[NSString stringWithFormat:@"Video (Part 2/2) Is Downloading \n\nProgress: 0.00%% \n\nDon't Exit The App"] preferredStyle:UIAlertControllerStyleAlert];

    [topViewController presentViewController:alertDownloading animated:YES completion:^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:audioURL];

        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float downloadPercent = downloadProgress.fractionCompleted * 100;
                alertDownloading.message = [NSString stringWithFormat:@"Video (Part 2/2) Is Downloading \n\nProgress: %.02f%% \n\nDon't Exit The App", downloadPercent];
            });
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            [alertDownloading dismissViewControllerAnimated:YES completion:^{
                UIAlertController *alertConverting = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Converting And Cleaning Up\nPlease Wait" preferredStyle:UIAlertControllerStyleAlert];
                [topViewController presentViewController:alertConverting animated:YES completion:^{
                    [FFmpegKit execute:[NSString stringWithFormat:@"-i %@ -c:a libmp3lame -q:a 8 %@/audio.mp3", filePath, documentsDirectory]];
                    [FFmpegKit execute:[NSString stringWithFormat:@"-i %@/video.mp4 -i %@/audio.mp3 -c:v copy -c:a aac %@/output.mp4", documentsDirectory, documentsDirectory, documentsDirectory]];
                    [[NSFileManager defaultManager] removeItemAtPath:[filePath path] error:nil];
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/video.mp4", documentsDirectory] error:nil];
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/audio.mp3", documentsDirectory] error:nil];

                    [alertConverting dismissViewControllerAnimated:YES completion:^{
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            NSURL *fileURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"output.mp4"]];
                            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
                        } completionHandler:^(BOOL success, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (success) {
                                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/output.mp4", documentsDirectory] error:nil];
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Video Download Complete And Saved To Camera Roll Successfully" preferredStyle:UIAlertControllerStyleAlert];
                                                        
                                    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                    }]];

                                    [topViewController presentViewController:alert animated:YES completion:nil];
                                } else{
                                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/output.mp4", documentsDirectory] error:nil];
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Save To Camera Roll Failed \nMake Sure To Give Camera Roll Permission To YouTube In The iOS Settings App" preferredStyle:UIAlertControllerStyleAlert];
                                                        
                                    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                    }]];

                                    [topViewController presentViewController:alert animated:YES completion:nil];
                                }
                            });
                        }];
                    }];
                }];
            }];
        }];
        [downloadTask resume];
    }];
}

@end