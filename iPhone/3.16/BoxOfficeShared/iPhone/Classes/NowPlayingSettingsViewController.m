// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "NowPlayingSettingsViewController.h"

#import "Application.h"
#import "Controller.h"
#import "DVDFilterViewController.h"
#import "LocationManager.h"
#import "Model.h"
#import "NowPlayingCreditsViewController.h"
#import "ScoreProviderViewController.h"
#import "SearchDatePickerViewController.h"
#import "SearchDistancePickerViewController.h"
#import "UserLocationCache.h"

@implementation NowPlayingSettingsViewController

static BOOL refreshed = NO;

typedef enum {
  SendFeedbackSection,
  StandardSettingsSection,
  UpcomingSection,
  DVDBluraySection,
  NetflixSection,
  RefreshSection,
  LastSection
} SettingsSection;


- (id) init {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = [Application nameAndVersion];
  }

  return self;
}


- (UserLocationCache*) userLocationCache {
  return [UserLocationCache cache];
}


- (void) minorRefresh {
  [self majorRefresh];
}


- (void) onBeforeViewControllerPushed {
  [super onBeforeViewControllerPushed];
  [[LocationManager manager] addLocationSpinner:self.navigationItem];
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)] autorelease];
}


- (void) onDone {
  [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
  return LastSection;
}


- (NSInteger)     tableView:(UITableView*) tableView
      numberOfRowsInSection:(NSInteger) section {
  if (section == SendFeedbackSection) {
    return 1;
  } else if (section == StandardSettingsSection) {
    return 8;
  } else if (section == UpcomingSection) {
    return 1;
  } else if (section == DVDBluraySection) {
    if ([Model model].dvdBlurayCacheEnabled) {
      return 2;
    } else {
      return 1;
    }
  } else if (section == NetflixSection) {
    if ([Model model].netflixCacheEnabled) {
      return 2;
    } else {
      return 1;
    }
  } else if (section == RefreshSection) {
    if ([Model model].userAddress.length == 0 || refreshed) {
      return 0;
    } else {
      return 1;
    }
  }

  return 0;
}


- (UITableViewCell*) cellForHeaderRow:(NSInteger) row {
  UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];

  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  NSString* text = [NSString stringWithFormat:@"%@ / %@", LocalizedString(@"About", @"Title for the 'About' page (where we list who was involved in making the program and who supplied the data)"), LocalizedString(@"Send Feedback", @"Title for a button that a user can click on to send a feedback email to the developers")];
  cell.textLabel.text = text;

  return cell;
}


- (UITableViewCell*) createSwitchCellWithText:(NSString*) text
                                           on:(BOOL) on
                                     selector:(SEL) selector {
  static NSString* reuseIdentifier = @"switchCellReuseIdentifier";

  SwitchCell* cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[SwitchCell alloc] initWithReuseIdentifier:reuseIdentifier] autorelease];
  }

  [cell.switchControl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
  [cell.switchControl addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
  cell.switchControl.on = on;
  cell.textLabel.text = text;

  return cell;
}


- (UITableViewCell*) createSettingCellWithKey:(NSString*) key
                                        value:(NSString*) value
                                  placeholder:(NSString*) placeholder {
  static NSString* reuseIdentifier = @"reuseIdentifier";
  SettingCell* cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[SettingCell alloc] initWithReuseIdentifier:reuseIdentifier] autorelease];
  }

  cell.placeholder = placeholder;
  cell.textLabel.text = key;
  [cell setCellValue:value];

  return cell;
}


- (UITableViewCell*) createSettingCellWithKey:(NSString*) key
                                        value:(NSString*) value {
  return [self createSettingCellWithKey:key value:value placeholder:@""];
}


- (UITableViewCell*) cellForSettingsRow:(NSInteger) row {
  if (row >= 0 && row <= 3) {
    NSString* key = @"";
    NSString* value = @"";
    NSString* placeholder = @"";
    if (row == 0) {
      key = LocalizedString(@"Location", nil);
      Location* location = [self.userLocationCache locationForUserAddress:[Model model].userAddress];
      if (location.postalCode.length == 0) {
        value = [Model model].userAddress;
      } else {
        value = location.postalCode;
      }
      placeholder = LocalizedString(@"Tap to enter location", nil);
    } else if (row == 1) {
      key = LocalizedString(@"Search Distance", nil);

      if ([Model model].searchRadius == 1) {
        value = ([Application useKilometers] ? LocalizedString(@"1 kilometer", nil) : LocalizedString(@"1 mile", nil));
      } else {
        value = [NSString stringWithFormat:LocalizedString(@"%d %@", @"5 kilometers or 5 miles"),
                 [Model model].searchRadius,
                 ([Application useKilometers] ? LocalizedString(@"kilometers", nil) : LocalizedString(@"miles", nil))];
      }
    } else if (row == 2) {
      key = LocalizedString(@"Search Date", @"This is noun, not a verb. It is the date we are getting movie listings for.");

      NSDate* date = [Model model].searchDate;
      if ([DateUtilities isToday:date]) {
        value = LocalizedString(@"Today", nil);
      } else {
        value = [DateUtilities formatLongDate:date];
      }
    } else if (row == 3) {
      key = LocalizedString(@"Reviews", nil);
      value = [Model model].currentScoreProvider;
    }

    return [self createSettingCellWithKey:key value:value placeholder:placeholder];
  } else if (row >= 4 && row <= 9) {
    NSString* text = @"";
    BOOL on = NO;
    SEL selector = nil;
    if (row == 4) {
      text = LocalizedString(@"Auto-Update Location", @"This string has to be small enough to be visible with a picker switch next to it.  It means 'automatically update the user's location with GPS information'");
      on = [Model model].autoUpdateLocation;
      selector = @selector(onAutoUpdateChanged:);
    } else if (row == 5) {
      text = LocalizedString(@"Use Small Fonts", @"This string has to be small enough to be visible with a picker switch next to it.  It means 'don't shrink the fonts when you have lots of stuff to display'");
      on = [Model model].useSmallFonts;
      selector = @selector(onUseSmallFontsChanged:);
    } else if (row == 6) {
      text = LocalizedString(@"Show Notifications", @"This string has to be small enough to be visible with a picker switch next to it.  It means 'show update notifications in the UI to let me know what's happening'");
      on = [Model model].notificationsEnabled;
      selector = @selector(onShowNotificationsChanged:);
    } else if (row == 7) {
      text = LocalizedString(@"Loading Indicators", @"This string has to be small enough to be visible with a picker switch next to it.  It means 'show update spinners in the UI when loading content'");
      on = [Model model].loadingIndicatorsEnabled;
      selector = @selector(onLoadingIndicatorsChanged:);
    }

    return [self createSwitchCellWithText:text on:on selector:selector];
  }

  return nil;
}


- (UITableViewCell*) cellForUpcomingRow:(NSInteger) row {
  return [self createSwitchCellWithText:LocalizedString(@"Enabled", nil)
                                     on:[Model model].upcomingCacheEnabled
                               selector:@selector(onUpcomingEnabledChanged:)];
}


- (UITableViewCell*) cellForDvdBlurayRow:(NSInteger) row {
  if (row == 0) {
    return [self createSwitchCellWithText:LocalizedString(@"Enabled", nil)
                                       on:[Model model].dvdBlurayCacheEnabled
                                 selector:@selector(onDvdBlurayEnabledChanged:)];
  } else {
    NSString* key = LocalizedString(@"Options", @"Button to change the visibility options for DVD or Bluray.");
    NSString* value = @"";

    if ([Model model].dvdMoviesShowBoth) {
      value = LocalizedString(@"Show Both", @"When the user wants to see 'Both' DVD and Bluray items");
    } else if ([Model model].dvdMoviesShowOnlyDVDs) {
      value = LocalizedString(@"DVD Only", @"When the user wants to see only DVD items and not Bluray");
    } else if ([Model model].dvdMoviesShowOnlyBluray) {
      value = LocalizedString(@"Blu-ray Only", @"When the user wants to see only Bluray items and not DVD");
    } else {
      value = LocalizedString(@"Show Neither", @"When the user does not want to see Bluray or DVD items");
    }

    return [self createSettingCellWithKey:key value:value];
  }
}


- (UITableViewCell*) cellForNetflixRow:(NSInteger) row {
  if (row == 0) {
    return [self createSwitchCellWithText:LocalizedString(@"Enabled", nil)
                                     on:[Model model].netflixCacheEnabled
                               selector:@selector(onNetflixEnabledChanged:)];
  } else {
    return [self createSwitchCellWithText:LocalizedString(@"Category Notifications", nil)
                                       on:[Model model].netflixNotificationsEnabled
                                 selector:@selector(onNetflixNotificationsChanged:)];
  }
}


- (UITableViewCell*) cellForRefreshRow:(NSInteger) row {
  UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
  cell.textLabel.textAlignment = UITextAlignmentCenter;
  cell.textLabel.text = LocalizedString(@"Force Refresh", nil);
  if (refreshed) {
    cell.textLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  } else {
    cell.textLabel.textColor = [ColorCache commandColor];
  }

  return cell;
}


- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
  if (indexPath.section == SendFeedbackSection) {
    return [self cellForHeaderRow:indexPath.row];
  } else if (indexPath.section == StandardSettingsSection) {
    return [self cellForSettingsRow:indexPath.row];
  } else if (indexPath.section == UpcomingSection) {
    return [self cellForUpcomingRow:indexPath.row];
  } else if (indexPath.section == DVDBluraySection) {
    return [self cellForDvdBlurayRow:indexPath.row];
  } else if (indexPath.section == NetflixSection) {
    return [self cellForNetflixRow:indexPath.row];
  } else {
    return [self cellForRefreshRow:indexPath.row];
  }
}


- (void) onNetflixEnabledChanged:(UISwitch*) sender {
  [[Controller controller] setNetflixEnabled:sender.on];

  NSArray* paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:NetflixSection]];
  if (sender.on) {
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
  } else {
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
  }
}


- (void) onUpcomingEnabledChanged:(UISwitch*) sender {
  [[Controller controller] setUpcomingEnabled:sender.on];
}


- (void) onDvdBlurayEnabledChanged:(UISwitch*) sender {
  [[Controller controller] setDvdBlurayEnabled:sender.on];

  NSArray* paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:DVDBluraySection]];
  if (sender.on) {
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
  } else {
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
  }
}


- (void) onAutoUpdateChanged:(UISwitch*) sender {
  [[Controller controller] setAutoUpdateLocation:sender.on];
}


- (void) onUseSmallFontsChanged:(UISwitch*) sender {
  [[Model model] setUseSmallFonts:sender.on];
}


- (void) onShowNotificationsChanged:(UISwitch*) sender {
  [[Model model] setNotificationsEnabled:sender.on];
}


- (void) onNetflixNotificationsChanged:(UISwitch*) sender {
  [[Model model] setNetflixNotificationsEnabled:sender.on];
}


- (void) onLoadingIndicatorsChanged:(UISwitch*) sender {
  [[Model model] setLoadingIndicatorsEnabled:sender.on];
}


- (void) pushSearchDatePicker {
  SearchDatePickerViewController* pickerController =
  [SearchDatePickerViewController pickerWithObject:self
                                          selector:@selector(onSearchDateChanged:)];

  [self.navigationController pushViewController:pickerController animated:YES];
}


- (void) onSearchDateChanged:(NSDate*) date {
  [[Controller controller] setSearchDate:date];
  [MetasyntacticSharedApplication majorRefresh:YES];
}


- (void) pushFilterDistancePicker {
  SearchDistancePickerViewController* controller =
  [[[SearchDistancePickerViewController alloc] init] autorelease];

  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectCreditsRow:(NSInteger) row {
  CreditsViewController* controller = [[[CreditsViewController alloc] init] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void) didSelectSettingsRow:(NSInteger) row {
  if (row == 0) {
    NSString* message;

    if ([Model model].userAddress.length == 0) {
      message = @"";
    } else {
      Location* location = [self.userLocationCache locationForUserAddress:[Model model].userAddress];
      if (location.postalCode == nil) {
        message = LocalizedString(@"Could not find location.", nil);
      } else {
        NSString* country = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode
                                                                  value:location.country];
        if (country == nil) {
          country = location.country;
        }

        message = [NSString stringWithFormat:@"%@, %@ %@\n%@\nLatitude: %f\nLongitude: %f",
                   location.city,
                   location.state,
                   location.postalCode,
                   country,
                   location.latitude,
                   location.longitude];
      }
    }

    TextFieldEditorViewController* controller =
    [[[TextFieldEditorViewController alloc] initWithTitle:LocalizedString(@"Location", nil)
                                                   object:self
                                                 selector:@selector(onUserAddressChanged:)
                                                     text:[Model model].userAddress
                                                  message:message
                                              placeHolder:LocalizedString(@"City/State or Postal Code", nil)
                                                     type:UIKeyboardTypeDefault] autorelease];

    [self.navigationController pushViewController:controller animated:YES];
  } else if (row == 1) {
    [self pushFilterDistancePicker];
  } else if (row == 2) {
    [self pushSearchDatePicker];
  } else if (row == 3) {
    ScoreProviderViewController* controller =
    [[[ScoreProviderViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
  }
}


- (void) didSelectUpcomingRow:(NSInteger) row {
}


- (void) didSelectDvdBlurayRow:(NSInteger) row {
  if (row == 1) {
    DVDFilterViewController* controller = [[[DVDFilterViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
  }
}


- (void) didSelectNetflixRow:(NSInteger) row {
}


- (void) didSelectRefreshRow:(NSInteger) row {
  if (refreshed) {
    return;
  }
  refreshed = YES;

  NSArray* indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:RefreshSection]];
  [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

  [[Controller controller] start:YES];
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
  if (indexPath.section == SendFeedbackSection) {
    [self didSelectCreditsRow:indexPath.row];
  } else if (indexPath.section == StandardSettingsSection) {
    [self didSelectSettingsRow:indexPath.row];
  } else if (indexPath.section == UpcomingSection) {
    [self didSelectUpcomingRow:indexPath.row];
  } else if (indexPath.section == DVDBluraySection) {
    [self didSelectDvdBlurayRow:indexPath.row];
  } else if (indexPath.section == NetflixSection) {
    [self didSelectNetflixRow:indexPath.row];
  } else {
    [self didSelectRefreshRow:indexPath.row];
  }
}


- (void) onUserAddressChanged:(NSString*) userAddress {
  userAddress = [userAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

  [[Controller controller] setUserAddress:userAddress];
  [MetasyntacticSharedApplication majorRefresh:YES];
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
  if (section == UpcomingSection) {
    return LocalizedString(@"Upcoming", nil);
  } else if (section == DVDBluraySection) {
    return LocalizedString(@"DVD/Blu-ray", nil);
  } else if (section == NetflixSection) {
    return LocalizedString(@"Netflix", nil);
  }

  return nil;
}

@end
