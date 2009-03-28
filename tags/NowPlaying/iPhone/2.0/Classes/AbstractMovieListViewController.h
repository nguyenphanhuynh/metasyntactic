// Copyright (C) 2008 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

@interface AbstractMovieListViewController : UITableViewController {
    AbstractNavigationController* navigationController;
    UISegmentedControl* segmentedControl;

    NSArray* sortedMovies;
    NSMutableArray* sectionTitles;
    MultiDictionary* sectionTitleToContentsMap;

    NSArray* alphabeticSectionTitles;
}

@property (assign) AbstractNavigationController* navigationController;
@property (retain) NSArray* sortedMovies;
@property (retain) UISegmentedControl* segmentedControl;
@property (retain) NSMutableArray* sectionTitles;
@property (retain) MultiDictionary* sectionTitleToContentsMap;
@property (retain) NSArray* alphabeticSectionTitles;

- (id) initWithNavigationController:(AbstractNavigationController*) navigationController;

- (void) refresh;

/* protected */
- (NowPlayingModel*) model;
- (NowPlayingController*) controller;


@end