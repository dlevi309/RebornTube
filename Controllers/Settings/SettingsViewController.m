// Main

#import "SettingsViewController.h"
#import "ThemeSettingsViewController.h"
#import "FontSettingsViewController.h"
#import "BackgroundModeSettingsViewController.h"
#import "SponsorBlockSettingsViewController.h"
#import "CreditsViewController.h"
#import "OpenSourceLibrariesViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppFonts.h"

// Interface

@interface SettingsViewController ()
@end

@implementation SettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"Settings";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    UILabel *doneLabel = [[UILabel alloc] init];
	doneLabel.text = @"Done";
	doneLabel.textColor = [UIColor systemBlueColor];
	doneLabel.numberOfLines = 1;
	[doneLabel setFont:[AppFonts mainFont:doneLabel.font.pointSize]];
	doneLabel.adjustsFontSizeToFitWidth = YES;
	doneLabel.userInteractionEnabled = YES;
	UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(done:)];
	doneTap.numberOfTapsRequired = 1;
	[doneLabel addGestureRecognizer:doneTap];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneLabel];
    self.navigationItem.leftBarButtonItem = doneButton;

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
        return 5;
    }
    if (section == 2) {
        return 1;
    }
    if (section == 3) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [AppColours viewBackgroundColour];
        cell.textLabel.textColor = [AppColours textColour];
        cell.detailTextLabel.textColor = [AppColours textColour];
        [cell.textLabel setFont:[AppFonts mainFont:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[AppFonts mainFont:cell.detailTextLabel.font.pointSize]];
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
                cell.textLabel.text = @"Font";
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"]) {
                    cell.detailTextLabel.text = @"Default";
                } else {
                    int selectedFontTag = [[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"];
                    if (selectedFontTag == 0) {
                        cell.detailTextLabel.text = @"Default";
                    }
                    if (selectedFontTag == 3) {
                        cell.detailTextLabel.text = @"Minecraft";
                    }
                    if (selectedFontTag == 4) {
                        cell.detailTextLabel.text = @"Tabitha";
                    }
                    if (selectedFontTag == 5) {
                        cell.detailTextLabel.text = @"Times New Roman";
                    }
                }
            }
            if (indexPath.row == 2) {
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
            if (indexPath.row == 3) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"SponsorBlock";
            }
            if (indexPath.row == 4) {
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
        }
        if (indexPath.section == 3) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Credits";
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Open-Source Libraries";
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
            FontSettingsViewController *fontSettingsViewController = [[FontSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:fontSettingsViewController animated:YES];
        }
        if (indexPath.row == 2) {
            BackgroundModeSettingsViewController *backgroundModeSettingsViewController = [[BackgroundModeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:backgroundModeSettingsViewController animated:YES];
        }
        if (indexPath.row == 3) {
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
                [fm removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"player.plist"] error:nil];
            }]];

            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            CreditsViewController *creditsViewController = [[CreditsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:creditsViewController animated:YES];
        }
        if (indexPath.row == 1) {
            OpenSourceLibrariesViewController *openSourceLibrariesViewController = [[OpenSourceLibrariesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:openSourceLibrariesViewController animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return 50;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return @"Version: 1.0.0 (Alpha 47)";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    [footer.textLabel setTextColor:[AppColours textColour]];
    [footer.textLabel setFont:[UIFont systemFontOfSize:14]];
    footer.textLabel.textAlignment = NSTextAlignmentCenter;
}

@end

@implementation SettingsViewController (Privates)

- (void)done:(UITapGestureRecognizer *)recognizer {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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

@end