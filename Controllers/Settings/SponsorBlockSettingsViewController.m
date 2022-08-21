// Main

#import "SponsorBlockSettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface SponsorBlockSettingsViewController ()
@end

@implementation SponsorBlockSettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1 || section == 2 || section == 3 || section == 4 || section == 5 || section == 6) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BackgroundModeSettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [AppColours viewBackgroundColour];
        cell.textLabel.textColor = [AppColours textColour];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                NSArray *sponsorItemArray = [NSArray arrayWithObjects:@"Disable", @"Auto Skip", nil];
                UISegmentedControl *sponsorSegmentedControl = [[UISegmentedControl alloc] initWithItems:sponsorItemArray];
                sponsorSegmentedControl.frame = CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                [sponsorSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateNormal];
                [sponsorSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateSelected];
                [sponsorSegmentedControl addTarget:self action:@selector(actionSponsorSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSponsorSegmentedInt"]) {
                    sponsorSegmentedControl.selectedSegmentIndex = 0;
                } else {
                    sponsorSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSponsorSegmentedInt"];
                }
                [cell addSubview:sponsorSegmentedControl];
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                NSArray *selfpromoItemArray = [NSArray arrayWithObjects:@"Disable", @"Auto Skip", nil];
                UISegmentedControl *selfpromoSegmentedControl = [[UISegmentedControl alloc] initWithItems:selfpromoItemArray];
                selfpromoSegmentedControl.frame = CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                [selfpromoSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateNormal];
                [selfpromoSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateSelected];
                [selfpromoSegmentedControl addTarget:self action:@selector(actionSelfPromoSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSelfPromoSegmentedInt"]) {
                    selfpromoSegmentedControl.selectedSegmentIndex = 0;
                } else {
                    selfpromoSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSelfPromoSegmentedInt"];
                }
                [cell addSubview:selfpromoSegmentedControl];
            }
        }
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                NSArray *interactionItemArray = [NSArray arrayWithObjects:@"Disable", @"Auto Skip", nil];
                UISegmentedControl *interactionSegmentedControl = [[UISegmentedControl alloc] initWithItems:interactionItemArray];
                interactionSegmentedControl.frame = CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                [interactionSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateNormal];
                [interactionSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateSelected];
                [interactionSegmentedControl addTarget:self action:@selector(actionInteractionSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockInteractionSegmentedInt"]) {
                    interactionSegmentedControl.selectedSegmentIndex = 0;
                } else {
                    interactionSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockInteractionSegmentedInt"];
                }
                [cell addSubview:interactionSegmentedControl];
            }
        }
        if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                NSArray *introItemArray = [NSArray arrayWithObjects:@"Disable", @"Auto Skip", nil];
                UISegmentedControl *introSegmentedControl = [[UISegmentedControl alloc] initWithItems:introItemArray];
                introSegmentedControl.frame = CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                [introSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateNormal];
                [introSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateSelected];
                [introSegmentedControl addTarget:self action:@selector(actionIntroSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockIntroSegmentedInt"]) {
                    introSegmentedControl.selectedSegmentIndex = 0;
                } else {
                    introSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockIntroSegmentedInt"];
                }
                [cell addSubview:introSegmentedControl];
            }
        }
        if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                NSArray *outroItemArray = [NSArray arrayWithObjects:@"Disable", @"Auto Skip", nil];
                UISegmentedControl *outroSegmentedControl = [[UISegmentedControl alloc] initWithItems:outroItemArray];
                outroSegmentedControl.frame = CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                [outroSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateNormal];
                [outroSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateSelected];
                [outroSegmentedControl addTarget:self action:@selector(actionOutroSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockOutroSegmentedInt"]) {
                    outroSegmentedControl.selectedSegmentIndex = 0;
                } else {
                    outroSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockOutroSegmentedInt"];
                }
                [cell addSubview:outroSegmentedControl];
            }
        }
        if (indexPath.section == 5) {
            if (indexPath.row == 0) {
                NSArray *previewItemArray = [NSArray arrayWithObjects:@"Disable", @"Auto Skip", nil];
                UISegmentedControl *previewSegmentedControl = [[UISegmentedControl alloc] initWithItems:previewItemArray];
                previewSegmentedControl.frame = CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                [previewSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateNormal];
                [previewSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateSelected];
                [previewSegmentedControl addTarget:self action:@selector(actionPreviewSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockPreviewSegmentedInt"]) {
                    previewSegmentedControl.selectedSegmentIndex = 0;
                } else {
                    previewSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockPreviewSegmentedInt"];
                }
                [cell addSubview:previewSegmentedControl];
            }
        }
        if (indexPath.section == 6) {
            if (indexPath.row == 0) {
                NSArray *musicofftopicItemArray = [NSArray arrayWithObjects:@"Disable", @"Auto Skip", nil];
                UISegmentedControl *musicofftopicSegmentedControl = [[UISegmentedControl alloc] initWithItems:musicofftopicItemArray];
                musicofftopicSegmentedControl.frame = CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                [musicofftopicSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateNormal];
                [musicofftopicSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[AppColours textColour]} forState:UIControlStateSelected];
                [musicofftopicSegmentedControl addTarget:self action:@selector(actionMusicOffTopicSegmentedControl:) forControlEvents:UIControlEventValueChanged];
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockMusicOffTopicSegmentedInt"]) {
                    musicofftopicSegmentedControl.selectedSegmentIndex = 0;
                } else {
                    musicofftopicSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockMusicOffTopicSegmentedInt"];
                }
                [cell addSubview:musicofftopicSegmentedControl];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1 || section == 2 || section == 3 || section == 4 || section == 5 || section == 6) {
        return 50;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Sponsor";
    }
    if (section == 1) {
        return @"Selfpromo";
    }
    if (section == 2) {
        return @"Interaction";
    }
    if (section == 3) {
        return @"Intro";
    }
    if (section == 4) {
        return @"Outro";
    }
    if (section == 5) {
        return @"Preview";
    }
    if (section == 6) {
        return @"Music_offtopic";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[AppColours textColour]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14]];
}

@end

@implementation SponsorBlockSettingsViewController (Privates)

- (void)actionSponsorSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"kSponsorBlockSponsorSegmentedInt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionSelfPromoSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"kSponsorBlockSelfPromoSegmentedInt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionInteractionSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"kSponsorBlockInteractionSegmentedInt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionIntroSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"kSponsorBlockIntroSegmentedInt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionOutroSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"kSponsorBlockOutroSegmentedInt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionPreviewSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"kSponsorBlockPreviewSegmentedInt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionMusicOffTopicSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"kSponsorBlockMusicOffTopicSegmentedInt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end