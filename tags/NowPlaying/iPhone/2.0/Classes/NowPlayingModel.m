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

#import "NowPlayingModel.h"

#import "AbstractNavigationController.h"
#import "AddressLocationCache.h"
#import "AllMoviesViewController.h"
#import "AllTheatersViewController.h"
#import "Application.h"
#import "DateUtilities.h"
#import "DifferenceEngine.h"
#import "FavoriteTheater.h"
#import "FileUtilities.h"
#import "GoogleDataProvider.h"
#import "IMDbCache.h"
#import "Location.h"
#import "Movie.h"
#import "MovieDetailsViewController.h"
#import "MovieRating.h"
#import "NowPlayingAppDelegate.h"
#import "NumbersCache.h"
#import "PosterCache.h"
#import "RatingsCache.h"
#import "ReviewCache.h"
#import "ReviewsViewController.h"
#import "Theater.h"
#import "TheaterDetailsViewController.h"
#import "ThreadingUtilities.h"
#import "TicketsViewController.h"
#import "TrailerCache.h"
#import "UpcomingCache.h"
#import "UpcomingMoviesViewController.h"
#import "UserLocationCache.h"
#import "Utilities.h"

@implementation NowPlayingModel

static NSString* currentVersion = @"2.0";
static NSString* persistenceVersion = @"65";

static NSString* VERSION = @"version";

static NSString* ALL_MOVIES_SELECTED_SEGMENT_INDEX      = @"allMoviesSelectedSegmentIndex";
static NSString* ALL_THEATERS_SELECTED_SEGMENT_INDEX    = @"allTheatersSelectedSegmentIndex";
static NSString* AUTO_UPDATE_LOCATION                   = @"autoUpdateLocation";
static NSString* FAVORITE_THEATERS                      = @"favoriteTheaters";
static NSString* NAVIGATION_STACK_TYPES                 = @"navigationStackTypes";
static NSString* NAVIGATION_STACK_VALUES                = @"navigationStackValues";
static NSString* NUMBERS_SELECTED_SEGMENT_INDEX         = @"numbersSelectedSegmentIndex";
static NSString* RATINGS_PROVIDER_INDEX                 = @"ratingsProviderIndex";
static NSString* SEARCH_DATE                            = @"searchDate";
static NSString* SEARCH_RADIUS                          = @"searchRadius";
static NSString* SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX = @"selectedTabBarViewControllerIndex";
static NSString* UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX = @"upcomingMoviesSelectedSegmentIndex";
static NSString* USER_ADDRESS                           = @"userLocation";
static NSString* USE_NORMAL_FONTS                       = @"useNormalFonts";


static NSString** KEYS[] = {
    &VERSION,
    &ALL_MOVIES_SELECTED_SEGMENT_INDEX,
    &ALL_THEATERS_SELECTED_SEGMENT_INDEX,
    &AUTO_UPDATE_LOCATION,
    &FAVORITE_THEATERS,
    &NAVIGATION_STACK_TYPES,
    &NAVIGATION_STACK_VALUES,
    &NUMBERS_SELECTED_SEGMENT_INDEX,
    &RATINGS_PROVIDER_INDEX,
    &SEARCH_DATE,
    &SEARCH_RADIUS,
    &SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX,
    &UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX,
    &USER_ADDRESS,
    &USE_NORMAL_FONTS,
};


@synthesize dataProvider;
@synthesize movieMap;
@synthesize movieMapLock;
@synthesize favoriteTheatersData;

@synthesize userLocationCache;
@synthesize imdbCache;
@synthesize numbersCache;
@synthesize posterCache;
@synthesize ratingsCache;
@synthesize reviewCache;
@synthesize trailerCache;
@synthesize upcomingCache;

- (void) dealloc {
    self.dataProvider = nil;
    self.movieMap = nil;
    self.movieMapLock = nil;
    self.favoriteTheatersData = nil;

    self.userLocationCache = nil;
    self.imdbCache = nil;
    self.numbersCache = nil;
    self.posterCache = nil;
    self.ratingsCache = nil;
    self.reviewCache = nil;
    self.trailerCache = nil;
    self.upcomingCache = nil;

    [super dealloc];
}


+ (NSString*) version {
    return currentVersion;
}


- (void) updateIMDbCache {
    [imdbCache update:self.movies];
}


- (void) updateNumbersCache {
    return;
    [numbersCache updateIndex];
}


- (void) updatePosterCache {
    [posterCache update:self.movies];
}


- (void) updateTrailerCache {
    [trailerCache update:self.movies];
}


- (NSDictionary*) ratings {
    return ratingsCache.ratings;
}


- (void) updateReviewCache {
    [reviewCache update:self.ratings ratingsProvider:self.ratingsProviderIndex];
}


- (void) updateUpcomingCache {
    [upcomingCache updateMovieDetails];
}


+ (void) saveFavoriteTheaters:(NSArray*) favoriteTheaters {
    NSMutableArray* result = [NSMutableArray array];
    for (FavoriteTheater* theater in favoriteTheaters) {
        [result addObject:theater.dictionary];
    }

    [[NSUserDefaults standardUserDefaults] setObject:result forKey:FAVORITE_THEATERS];

}


- (void) restorePreviousUserAddress:(id) previousUserAddress
                       searchRadius:(id) previousSearchRadius
                 autoUpdateLocation:(id) previousAutoUpdateLocation
                     useNormalFonts:(id) previousUseNormalFonts
                   favoriteTheaters:(id) previousFavoriteTheaters {
    if ([previousUserAddress isKindOfClass:[NSString class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:previousUserAddress forKey:USER_ADDRESS];
    }

    if ([previousSearchRadius isKindOfClass:[NSNumber class]]) {
        [[NSUserDefaults standardUserDefaults] setInteger:[previousSearchRadius intValue] forKey:SEARCH_RADIUS];
    }

    if ([previousAutoUpdateLocation isKindOfClass:[NSNumber class]]) {
        [[NSUserDefaults standardUserDefaults] setBool:[previousAutoUpdateLocation boolValue] forKey:AUTO_UPDATE_LOCATION];
    }

    if ([previousUseNormalFonts isKindOfClass:[NSNumber class]]) {
        [[NSUserDefaults standardUserDefaults] setBool:[previousUseNormalFonts boolValue] forKey:USE_NORMAL_FONTS];
    }

    if ([previousFavoriteTheaters isKindOfClass:[NSArray class]]) {
        NSMutableArray* favoriteTheaters = [NSMutableArray array];

        for (id previousTheater in previousFavoriteTheaters) {
            if (![previousTheater isKindOfClass:[NSDictionary class]]) {
                continue;
            }

            if (![FavoriteTheater canReadDictionary:previousTheater]) {
                continue;
            }

            FavoriteTheater* theater = [FavoriteTheater theaterWithDictionary:previousTheater];
            [favoriteTheaters addObject:theater];
        }

        [NowPlayingModel saveFavoriteTheaters:favoriteTheaters];
    }
}


- (void) loadData {
    self.dataProvider = [GoogleDataProvider providerWithModel:self];

    self.movieMap = [NSDictionary dictionaryWithContentsOfFile:[Application movieMapFile]];

    NSString* version = [[NSUserDefaults standardUserDefaults] objectForKey:VERSION];
    if (version == nil || ![persistenceVersion isEqual:version]) {
        id previousUserAddress = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ADDRESS];
        id previousSearchRadius = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_RADIUS];
        id previousAutoUpdateLocation = [[NSUserDefaults standardUserDefaults] objectForKey:AUTO_UPDATE_LOCATION];
        id previousUseNormalFonts = [[NSUserDefaults standardUserDefaults] objectForKey:USE_NORMAL_FONTS];
        id previousFavoriteTheaters = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_THEATERS];

        self.movieMap = nil;
        for (int i = 0; i < ArrayLength(KEYS); i++) {
            NSString** key = KEYS[i];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:*key];
        }

        [Application deleteFolders];

        [dataProvider invalidateDiskCache];

        [self restorePreviousUserAddress:previousUserAddress
                            searchRadius:previousSearchRadius
                      autoUpdateLocation:previousAutoUpdateLocation
                          useNormalFonts:previousUseNormalFonts
                        favoriteTheaters:previousFavoriteTheaters];

        [[NSUserDefaults standardUserDefaults] setObject:persistenceVersion forKey:VERSION];
    }
}


- (void) regenerateMovieMap {
    NSArray* arguments = [NSArray arrayWithObjects:self.ratings, self.movies, nil];
    [ThreadingUtilities performSelector:@selector(createMovieMap:)
                               onTarget:self
               inBackgroundWithArgument:arguments
                                   gate:movieMapLock
                                visible:NO
                            lowPriority:NO];
}


- (void) createMovieMap:(NSArray*) arguments {
    NSDictionary* ratings = [arguments objectAtIndex:0];
    NSArray* movies = [arguments objectAtIndex:1];

    NSMutableDictionary* result = [NSMutableDictionary dictionary];

    NSArray* keys = ratings.allKeys;
    NSMutableArray* lowercaseKeys = [NSMutableArray array];
    for (NSString* key in keys) {
        [lowercaseKeys addObject:key.lowercaseString];
    }

    DifferenceEngine* engine = [DifferenceEngine engine];

    for (Movie* movie in movies) {
        NSString* lowercaseTitle = movie.canonicalTitle.lowercaseString;
        NSInteger index = [lowercaseKeys indexOfObject:lowercaseTitle];
        if (index == NSNotFound) {
            index = [engine findClosestMatchIndex:movie.canonicalTitle.lowercaseString inArray:lowercaseKeys];
        }

        if (index != NSNotFound) {
            NSString* key = [keys objectAtIndex:index];
            [result setObject:key forKey:movie.canonicalTitle];
        }
    }

    [FileUtilities writeObject:result toFile:[Application movieMapFile]];
    [self performSelectorOnMainThread:@selector(reportMovieMap:) withObject:result waitUntilDone:NO];
}


- (void) reportMovieMap:(NSDictionary*) result {
    self.movieMap = result;
    [NowPlayingAppDelegate refresh];
}


- (id) init {
    if (self = [super init]) {
        [self loadData];

        self.userLocationCache = [UserLocationCache cache];
        self.imdbCache = [IMDbCache cache];
        self.numbersCache = [NumbersCache cache];
        self.posterCache = [PosterCache cacheWithModel:self];
        self.reviewCache = [ReviewCache cacheWithModel:self];
        self.ratingsCache = [RatingsCache cacheWithModel:self];
        self.trailerCache = [TrailerCache cache];
        self.upcomingCache = [UpcomingCache cache];
        self.movieMapLock = [[[NSLock alloc] init] autorelease];

        searchRadius = -1;

        if(movieMap == nil) {
            [self regenerateMovieMap];
        }
        [self performSelector:@selector(updateCaches:) withObject:[NSNumber numberWithInt:0] afterDelay:2];
    }

    return self;
}


- (void) updateCaches:(NSNumber*) number {
    int value = number.intValue;

    SEL selectors[] = {
        @selector(updateNumbersCache),
        @selector(updatePosterCache),
        @selector(updateReviewCache),
        @selector(updateTrailerCache),
        @selector(updateUpcomingCache),
        @selector(updateIMDbCache)
    };

    if (value >= ArrayLength(selectors)) {
        return;
    }

    [self performSelector:selectors[value]];
    [self performSelector:@selector(updateCaches:) withObject:[NSNumber numberWithInt:value + 1] afterDelay:1];
}


+ (NowPlayingModel*) model {
    return [[[NowPlayingModel alloc] init] autorelease];
}


- (id<DataProvider>) dataProvider {
    return dataProvider;
}


- (NSInteger) ratingsProviderIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:RATINGS_PROVIDER_INDEX];
}


- (void) setRatingsProviderIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:RATINGS_PROVIDER_INDEX];
    [ratingsCache onRatingsProviderChanged];
    [self regenerateMovieMap];
    [self updateReviewCache];

    if (self.noRatings && self.allMoviesSortingByScore) {
        [self setAllMoviesSelectedSegmentIndex:0];
    }
}


- (BOOL) rottenTomatoesRatings {
    return self.ratingsProviderIndex == 0;
}


- (BOOL) metacriticRatings {
    return self.ratingsProviderIndex == 1;
}


- (BOOL) googleRatings {
    return self.ratingsProviderIndex == 2;
}


- (BOOL) noRatings {
    return self.ratingsProviderIndex == 3;
}


- (NSArray*) ratingsProviders {
    return [NSArray arrayWithObjects:
            @"RottenTomatoes",
            @"Metacritic",
            @"Google",
            NSLocalizedString(@"None", nil), nil];
}


- (NSString*) currentRatingsProvider {
    return [self.ratingsProviders objectAtIndex:self.ratingsProviderIndex];
}


- (NSInteger) selectedTabBarViewControllerIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX];
}


- (void) setSelectedTabBarViewControllerIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:SELECTED_TAB_BAR_VIEW_CONTROLLER_INDEX];
}


- (NSInteger) allMoviesSelectedSegmentIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:ALL_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (void) setAllMoviesSelectedSegmentIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:ALL_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (NSInteger) allTheatersSelectedSegmentIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:ALL_THEATERS_SELECTED_SEGMENT_INDEX];
}


- (void) setAllTheatersSelectedSegmentIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:ALL_THEATERS_SELECTED_SEGMENT_INDEX];
}

- (NSInteger) upcomingMoviesSelectedSegmentIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (void) setUpcomingMoviesSelectedSegmentIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:UPCOMING_MOVIES_SELECTED_SEGMENT_INDEX];
}


- (NSInteger) numbersSelectedSegmentIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:NUMBERS_SELECTED_SEGMENT_INDEX];
}


- (void) setNumbersSelectedSegmentIndex:(NSInteger) index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:NUMBERS_SELECTED_SEGMENT_INDEX];
}


- (BOOL) allMoviesSortingByTitle {
    return self.allMoviesSelectedSegmentIndex == 0;
}


- (BOOL) allMoviesSortingByReleaseDate {
    return self.allMoviesSelectedSegmentIndex == 1;
}


- (BOOL) allMoviesSortingByScore {
    return self.allMoviesSelectedSegmentIndex == 2;
}


- (BOOL) upcomingMoviesSortingByTitle {
    return self.upcomingMoviesSelectedSegmentIndex == 0;
}


- (BOOL) upcomingMoviesSortingByReleaseDate {
    return self.upcomingMoviesSelectedSegmentIndex == 1;
}


- (BOOL) numbersSortingByDailyGross {
    return self.numbersSelectedSegmentIndex == 0;
}


- (BOOL) numbersSortingByWeekendGross {
    return self.numbersSelectedSegmentIndex == 1;
}


- (BOOL) numbersSortingByTotalGross {
    return self.numbersSelectedSegmentIndex == 2;
}


- (BOOL) autoUpdateLocation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:AUTO_UPDATE_LOCATION];
}


- (void) setAutoUpdateLocation:(BOOL) value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:AUTO_UPDATE_LOCATION];
}


- (NSString*) userAddress {
    NSString* result = [[NSUserDefaults standardUserDefaults] stringForKey:USER_ADDRESS];
    if (result == nil) {
        result =  @"";
    }

    return result;
}


- (int) searchRadius {
    if (searchRadius == -1) {
        searchRadius = [[NSUserDefaults standardUserDefaults] integerForKey:SEARCH_RADIUS];
        if (searchRadius == 0) {
            searchRadius = 5;
        }

        searchRadius = MAX(MIN(searchRadius, 50), 1);
    }

    return searchRadius;
}


- (void) setSearchRadius:(NSInteger) radius {
    searchRadius = radius;
    [[NSUserDefaults standardUserDefaults] setInteger:searchRadius forKey:SEARCH_RADIUS];
}


- (NSDate*) searchDate {
    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_DATE];
    if (date == nil || [date compare:[NSDate date]] == NSOrderedAscending) {
        return [DateUtilities today];
    }
    return date;
}


- (void) markDataProviderOutOfDate {
    [dataProvider setStale];
}


- (void) setSearchDate:(NSDate*) date {
    [self markDataProviderOutOfDate];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:SEARCH_DATE];
}


- (NSArray*) movies {
    return [dataProvider movies];
}


- (NSArray*) theaters {
    return [dataProvider theaters];
}


- (void) onRatingsUpdated {
    [self regenerateMovieMap];
    [self updateReviewCache];
}


- (void) onProviderUpdated {
    [self regenerateMovieMap];
    [self updateIMDbCache];
    [self updatePosterCache];
    [self updateTrailerCache];
}


- (NSMutableArray*) loadFavoriteTheaters {
    NSArray* array = [[NSUserDefaults standardUserDefaults] arrayForKey:FAVORITE_THEATERS];
    if (array.count == 0) {
        return [NSMutableArray array];
    }

    NSMutableArray* result = [NSMutableArray array];
    for (NSDictionary* dictionary in array) {
        [result addObject:[FavoriteTheater theaterWithDictionary:dictionary]];
    }

    return result;
}


- (NSMutableArray*) favoriteTheaters {
    if (favoriteTheatersData == nil) {
        self.favoriteTheatersData = [self loadFavoriteTheaters];
    }

    return favoriteTheatersData;
}


- (void) saveFavoriteTheaters {
    [NowPlayingModel saveFavoriteTheaters:self.favoriteTheaters];
}


- (void) addFavoriteTheater:(Theater*) theater {
    FavoriteTheater* favoriteTheater = [FavoriteTheater theaterWithName:theater.name
                                                    originatingLocation:theater.originatingLocation];
    if (![self.favoriteTheaters containsObject:favoriteTheater]) {
        [self.favoriteTheaters addObject:favoriteTheater];
    }

    [self saveFavoriteTheaters];
}


- (BOOL) isFavoriteTheater:(Theater*) theater {
    for (FavoriteTheater* favorite in self.favoriteTheaters) {
        if ([favorite.name isEqual:theater.name]) {
            return YES;
        }
    }

    return NO;
}


- (void) removeFavoriteTheater:(Theater*) theater {
    FavoriteTheater* favoriteTheater = [FavoriteTheater theaterWithName:theater.name
                                                    originatingLocation:theater.originatingLocation];

    [self.favoriteTheaters removeObject:favoriteTheater];
    [self saveFavoriteTheaters];
}


- (NSDate*) releaseDateForMovie:(Movie*) movie {
    if (movie.releaseDate != nil) {
        return movie.releaseDate;
    }

    return [upcomingCache releaseDateForMovie:movie];
}


- (NSArray*) directorsForMovie:(Movie*) movie {
    if (movie.directors.count > 0) {
        return movie.directors;
    }

    return [upcomingCache directorsForMovie:movie];
}


- (NSArray*) castForMovie:(Movie*) movie {
    if (movie.cast.count > 0) {
        return movie.cast;
    }

    return [upcomingCache castForMovie:movie];
}


- (NSArray*) genresForMovie:(Movie*) movie {
    if (movie.genres.count > 0) {
        return movie.genres;
    }

    return [upcomingCache genresForMovie:movie];
}


- (NSString*) imdbAddressForMovie:(Movie*) movie {
    if (movie.imdbAddress.length > 0) {
        return movie.imdbAddress;
    }

    NSString* result = [imdbCache imdbAddressForMovie:movie];
    if (result.length > 0) {
        return result;
    }

    return [upcomingCache imdbAddressForMovie:movie];
}


- (UIImage*) posterForMovie:(Movie*) movie {
    UIImage* image = [posterCache posterForMovie:movie];
    if (image != nil) {
        return image;
    }

    return [upcomingCache posterForMovie:movie];
}


- (NSMutableArray*) theatersShowingMovie:(Movie*) movie {
    NSMutableArray* array = [NSMutableArray array];

    for (Theater* theater in self.theaters) {
        if ([theater.movieTitles containsObject:movie.canonicalTitle]) {
            [array addObject:theater];
        }
    }

    return array;
}


- (NSArray*) moviesAtTheater:(Theater*) theater {
    NSMutableArray* array = [NSMutableArray array];

    for (Movie* movie in self.movies) {
        if ([theater.movieTitles containsObject:movie.canonicalTitle]) {
            [array addObject:movie];
        }
    }

    return array;
}


- (NSArray*) moviePerformances:(Movie*) movie forTheater:(Theater*) theater {
    return [dataProvider moviePerformances:movie forTheater:theater];
}


- (NSDate*) synchronizationDateForTheater:(Theater*) theater {
    return [dataProvider synchronizationDateForTheater:theater.name];
}


- (BOOL) isStale:(Theater*) theater {
    NSDate* globalSyncDate = [dataProvider lastLookupDate];
    NSDate* theaterSyncDate = [self synchronizationDateForTheater:theater];
    if (globalSyncDate == nil || theaterSyncDate == nil) {
        return NO;
    }

    return ![DateUtilities isSameDay:globalSyncDate date:theaterSyncDate];
}


- (NSString*) showtimesRetrievedOnString:(Theater*) theater {
    if ([self isStale:theater]) {
        // we're showing out of date information
        NSDate* theaterSyncDate = [self synchronizationDateForTheater:theater];
        return [NSString stringWithFormat:
                NSLocalizedString(@"Theater last reported show times on\n%@.", nil),
                [DateUtilities formatLongDate:theaterSyncDate]];
    } else {
        NSDate* globalSyncDate = [dataProvider lastLookupDate];
        if (globalSyncDate == nil) {
            return @"";
        }

        return [NSString stringWithFormat:
                NSLocalizedString(@"Show times retrieved on %@.", nil),
                [DateUtilities formatLongDate:globalSyncDate]];
    }
}


- (NSString*) simpleAddressForTheater:(Theater*) theater {
    Location* location = theater.location;
    if (location.address.length != 0 && location.city.length != 0) {
        return [NSString stringWithFormat:@"%@, %@", location.address, location.city];
    } else {
        return location.address;
    }
}


- (NSDictionary*) theaterDistanceMap {
    Location* location = [userLocationCache locationForUserAddress:self.userAddress];
    return [AddressLocationCache theaterDistanceMap:location
                                           theaters:self.theaters];
}


- (BOOL) tooFarAway:(double) distance {
    if (distance != UNKNOWN_DISTANCE && self.searchRadius < 50 && distance > self.searchRadius) {
        return true;
    }

    return false;
}


- (NSArray*) theatersInRange:(NSArray*) theaters {
    NSDictionary* theaterDistanceMap = [self theaterDistanceMap];
    NSMutableArray* result = [NSMutableArray array];

    for (Theater* theater in theaters) {
        double distance = [[theaterDistanceMap objectForKey:theater.name] doubleValue];

        if ([self isFavoriteTheater:theater] || ![self tooFarAway:distance]) {
            [result addObject:theater];
        }
    }

    return result;
}


NSInteger compareMoviesByScore(id t1, id t2, void *context) {
    Movie* movie1 = t1;
    Movie* movie2 = t2;
    NowPlayingModel* model = context;

    int movieRating1 = [model scoreForMovie:movie1];
    int movieRating2 = [model scoreForMovie:movie2];

    if (movieRating1 < movieRating2) {
        return NSOrderedDescending;
    } else if (movieRating1 > movieRating2) {
        return NSOrderedAscending;
    }

    return compareMoviesByTitle(t1, t2, context);
}


NSInteger compareMoviesByReleaseDateDescending(id t1, id t2, void *context) {
    NowPlayingModel* model = context;
    Movie* movie1 = t1;
    Movie* movie2 = t2;

    NSDate* releaseDate1 = [model releaseDateForMovie:movie1];
    NSDate* releaseDate2 = [model releaseDateForMovie:movie2];

    if (releaseDate1 == nil) {
        if (releaseDate2 == nil) {
            return compareMoviesByTitle(movie1, movie2, context);
        } else {
            return NSOrderedDescending;
        }
    } else if (releaseDate2 == nil) {
        return NSOrderedAscending;
    }

    return -[releaseDate1 compare:releaseDate2];
}


NSInteger compareMoviesByReleaseDateAscending(id t1, id t2, void *context) {
    return -compareMoviesByReleaseDateDescending(t1, t2, context);
}


NSInteger compareMoviesByTitle(id t1, id t2, void *context) {
    Movie* movie1 = t1;
    Movie* movie2 = t2;

    return [movie1.displayTitle compare:movie2.displayTitle options:NSCaseInsensitiveSearch];
}


NSInteger compareTheatersByName(id t1, id t2, void *context) {
    Theater* theater1 = t1;
    Theater* theater2 = t2;

    return [theater1.name compare:theater2.name options:NSCaseInsensitiveSearch];
}


NSInteger compareTheatersByDistance(id t1, id t2, void *context) {
    NSDictionary* theaterDistanceMap = context;

    Theater* theater1 = t1;
    Theater* theater2 = t2;

    double distance1 = [[theaterDistanceMap objectForKey:theater1.name] doubleValue];
    double distance2 = [[theaterDistanceMap objectForKey:theater2.name] doubleValue];

    if (distance1 < distance2) {
        return NSOrderedAscending;
    } else if (distance1 > distance2) {
        return NSOrderedDescending;
    }

    return compareTheatersByName(t1, t2, nil);
}


- (void) setUserAddress:(NSString*) userAddress {
    [self markDataProviderOutOfDate];

    [[NSUserDefaults standardUserDefaults] setObject:userAddress forKey:USER_ADDRESS];
}


- (MovieRating*) extraInformationForMovie:(Movie*) movie {
    NSString* key = [movieMap objectForKey:movie.canonicalTitle];
    if (key == nil) {
        return nil;
    }

    return [self.ratings objectForKey:key];
}


- (NSInteger) scoreForMovie:(Movie*) movie {
    MovieRating* extraInfo = [self extraInformationForMovie:movie];

    if (extraInfo == nil) {
        return -1;
    }

    return extraInfo.scoreValue;
}


- (NSString*) synopsisForMovie:(Movie*) movie {
    NSMutableArray* options = [NSMutableArray array];
    NSString* synopsis = movie.synopsis;
    if (synopsis.length > 0) {
        [options addObject:synopsis];
    }

    if (options.count == 0 || [[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] hasPrefix:@"en"]) {
        synopsis = [self extraInformationForMovie:movie].synopsis;
        if (synopsis.length > 0) {
            [options addObject:synopsis];
        }

        synopsis = [upcomingCache synopsisForMovie:movie];
        if (synopsis.length > 0) {
            [options addObject:synopsis];
        }
    }

    if (options.count == 0) {
        return NSLocalizedString(@"No synopsis available.", nil);
    }


    NSString* bestOption = @"";
    for (NSString* option in options) {
        if (option.length > bestOption.length) {
            bestOption = option;
        }
    }

    return bestOption;
}


- (NSArray*) trailersForMovie:(Movie*) movie {
    NSArray* result = [trailerCache trailersForMovie:movie];
    if (result.count > 0) {
        return result;
    }

    return [upcomingCache trailersForMovie:movie];
}


- (NSArray*) reviewsForMovie:(Movie*) movie {
    MovieRating* extraInfo = [self extraInformationForMovie:movie];
    if (extraInfo == nil) {
        return [NSArray array];
    }

    return [reviewCache reviewsForMovie:extraInfo.canonicalTitle];
}


- (NSString*) noLocationInformationFound {
    if (self.userAddress.length == 0) {
        return NSLocalizedString(@"Please enter your location", nil);
    } else {
        return NSLocalizedString(@"No information found", nil);
    }
}


- (BOOL) useSmallFonts {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:USE_NORMAL_FONTS];
}


- (void) setUseSmallFonts:(BOOL) useSmallFonts {
    [[NSUserDefaults standardUserDefaults] setBool:!useSmallFonts forKey:USE_NORMAL_FONTS];
}


- (void) saveNavigationStack:(AbstractNavigationController*) controller {
    NSMutableArray* types = [NSMutableArray array];
    NSMutableArray* values = [NSMutableArray array];

    for (id viewController in controller.viewControllers) {
        NSInteger type;
        id value;
        if ([viewController isKindOfClass:[MovieDetailsViewController class]]) {
            type = MovieDetails;
            value = [[viewController movie] dictionary];
        } else if ([viewController isKindOfClass:[TheaterDetailsViewController class]]) {
            type = TheaterDetails;
            value = [[viewController theater] dictionary];
        } else if ([viewController isKindOfClass:[ReviewsViewController class]]) {
            type = Reviews;
            value = [[viewController movie] dictionary];
        } else if ([viewController isKindOfClass:[TicketsViewController class]]) {
            type = Tickets;
            value = [NSArray arrayWithObjects:[[viewController movie] dictionary], [[viewController theater] dictionary], [viewController title], nil];
        } else if ([viewController isKindOfClass:[AllMoviesViewController class]]) {
            continue;
        } else if ([viewController isKindOfClass:[AllTheatersViewController class]]) {
            continue;
        } else if ([viewController isKindOfClass:[UpcomingMoviesViewController class]]) {
            continue;
        } else {
            NSAssert(false, @"");
        }

        [types addObject:[NSNumber numberWithInt:type]];
        [values addObject:value];
    }

    [[NSUserDefaults standardUserDefaults] setObject:types forKey:NAVIGATION_STACK_TYPES];
    [[NSUserDefaults standardUserDefaults] setObject:values forKey:NAVIGATION_STACK_VALUES];
}


- (NSArray*) navigationStackTypes {
    NSArray* result = [[NSUserDefaults standardUserDefaults] arrayForKey:NAVIGATION_STACK_TYPES];
    if (result == nil) {
        return [NSArray array];
    }

    return result;
}


- (NSArray*) navigationStackValues {
    NSArray* result = [[NSUserDefaults standardUserDefaults] arrayForKey:NAVIGATION_STACK_VALUES];
    if (result == nil) {
        return [NSArray array];
    }

    return result;
}

@end