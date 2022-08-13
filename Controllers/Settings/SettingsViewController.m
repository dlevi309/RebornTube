// Main

#import "SettingsViewController.h"
#import "ThemeSettingsViewController.h"
#import "BackgroundModeSettingsViewController.h"
#import "SponsorBlockSettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface SettingsViewController ()
@end

@implementation SettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(apply)];
    self.navigationItem.rightBarButtonItem = applyButton;

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 4;
    }
    if (section == 2) {
        return 2;
    }
    if (section == 3) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        cell.textLabel.adjustsFontForContentSizeCategory = false;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = true;
        cell.detailTextLabel.adjustsFontForContentSizeCategory = false;
        cell.backgroundColor = [AppColours viewBackgroundColour];
        cell.textLabel.textColor = [AppColours textColour];
        cell.detailTextLabel.textColor = [AppColours textColour];
        if (indexPath.section == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Patreon";
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"Theme";
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"]) {
                    cell.detailTextLabel.text = @"Auto (Device)";
                } else {
                    int selectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"];
                    if (selectedTab == 0) {
                        cell.detailTextLabel.text = @"Auto (Device)";
                    }
                    if (selectedTab == 1) {
                        cell.detailTextLabel.text = @"Light";
                    }
                    if (selectedTab == 2) {
                        cell.detailTextLabel.text = @"Dark";
                    }
                    if (selectedTab == 3) {
                        cell.detailTextLabel.text = @"Pure Dark";
                    }
                }
            }
            if (indexPath.row == 1) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"Background Mode";
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"]) {
                    cell.detailTextLabel.text = @"None";
                } else {
                    int selectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"];
                    if (selectedTab == 0) {
                        cell.detailTextLabel.text = @"None";
                    }
                    if (selectedTab == 1) {
                        cell.detailTextLabel.text = @"Background Playback";
                    }
                    if (selectedTab == 2) {
                        cell.detailTextLabel.text = @"Picture In Picture";
                    }
                }
            }
            if (indexPath.row == 2) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"SponsorBlock";
            }
            if (indexPath.row == 3) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"Enable Captions";
                cell.detailTextLabel.text = @"Make sure captions is on in iOS settings";
                UISwitch *enableCaptions = [[UISwitch alloc] initWithFrame:CGRectZero];
                [enableCaptions addTarget:self action:@selector(toggleEnableCaptions:) forControlEvents:UIControlEventValueChanged];
                enableCaptions.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableCaptions"];
                cell.accessoryView = enableCaptions;
            }
        }
        if (indexPath.section == 2) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Clear History";
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Clear Playlists";
            }
        }

        if (indexPath.section == 3) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Enable Developer Options";
                cell.detailTextLabel.text = @"Not Recommended";
                UISwitch *enableDeveloperOptions = [[UISwitch alloc] initWithFrame:CGRectZero];
                [enableDeveloperOptions addTarget:self action:@selector(toggleEnableDeveloperOptions:) forControlEvents:UIControlEventValueChanged];
                enableDeveloperOptions.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableDeveloperOptions"];
                cell.accessoryView = enableDeveloperOptions;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.patreon.com/lillieweeb"] options:@{} completionHandler:nil];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            ThemeSettingsViewController *themeSettingsViewController = [[ThemeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:themeSettingsViewController animated:YES];
        }
        if (indexPath.row == 1) {
            BackgroundModeSettingsViewController *backgroundModeSettingsViewController = [[BackgroundModeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:backgroundModeSettingsViewController animated:YES];
        }
        if (indexPath.row == 2) {
            SponsorBlockSettingsViewController *sponsorBlockSettingsViewController = [[SponsorBlockSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:sponsorBlockSettingsViewController animated:YES];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Are you sure you want to delete your history?" preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];

            [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSFileManager *fm = [[NSFileManager alloc] init];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"history.plist"] error:nil];
            }]];

            [self presentViewController:alert animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Are you sure you want to delete your playlists?" preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];

            [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSFileManager *fm = [[NSFileManager alloc] init];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"playlists.plist"] error:nil];
            }]];

            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

@end

@implementation SettingsViewController (Privates)

- (void)apply {
    exit(0); 
}

- (void)toggleEnableCaptions:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableCaptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableCaptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleEnableDeveloperOptions:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableDeveloperOptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableDeveloperOptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end