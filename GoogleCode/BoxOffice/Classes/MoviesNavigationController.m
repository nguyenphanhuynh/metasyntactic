// Copyright (C) 2008 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "MoviesNavigationController.h"

#import "AllMoviesViewController.h"

@implementation MoviesNavigationController

@synthesize allMoviesViewController;
@synthesize tabBarController;

- (void) dealloc {
    self.allMoviesViewController = nil;
    self.tabBarController = nil;

    [super dealloc];
}


- (id) initWithTabBarController:(ApplicationTabBarController*) controller {
    if (self = [super initWithTabBarController:controller]) {
        self.allMoviesViewController = [[[AllMoviesViewController alloc] initWithNavigationController:self] autorelease];

        [self pushViewController:allMoviesViewController animated:NO];

        self.title = NSLocalizedString(@"Movies", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"Featured.png"];
    }

    return self;
}


- (void) refresh {
    [super refresh];
    
    for (id controller in self.viewControllers) {
        [controller refresh];
    }
}


@end
