//
//  CityData.m
//  GifuGuide
//
//  Created by admin on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CityData.h"
//#import "JSON.h"
#import "FMDatabase.h"

@interface CityData ()
@property (nonatomic, retain) NSMutableData *data;
//@property (nonatomic, retain) NSArray *root;
@end

@interface CityData (Private)
- (int)areaMaxId:(FMDatabase *)db;
- (int)cityMaxId:(FMDatabase *)db;
@end

static CityData *_sharedCityData = nil;

@implementation CityData

@synthesize delegate;
@synthesize data;
//@synthesize root;

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

+ (CityData *)sharedCityData
{
    @synchronized(self) {
        if (!_sharedCityData) {
            _sharedCityData = [[self alloc] init];
        }
    }
    return _sharedCityData;
}

- (id)init{
    self = [super init];

    if (!self) {
        return nil;
    }

    //NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CityData" ofType:@"plist"];
    //self.root = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"Root"];

    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"cities" withExtension:@"json"];
    //NSData *data = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
    //NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    //self.root = [jsonString JSONValue];

    imageCache_ = [[NSMutableDictionary alloc] init];

    //copy database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dbPath_ = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"gifu.db"] retain];

    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"gifu.db"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dbPath_]) {
        [fileManager removeItemAtPath:dbPath_ error:nil]; //上書きコピーできないので先に消す
    }
    NSError *error;
    if ([fileManager copyItemAtPath:resourcePath toPath:dbPath_ error:&error] == NO) {
        NSLog(@"DB COPY ERROR! %@", [error localizedDescription]);
    }

    return self;
}

- (void)dealloc
{
    delegate = nil;

    [imageCache_ release], imageCache_ = nil;
    [dbPath_ release], dbPath_ = nil;

    [data release], data = nil;
    //[root release], root = nil;

    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- CityData methods --
//--------------------------------------------------------------//

- (void)loadCityData:(id<CityDataDelegate>)cityDataDelegate
{
    self.delegate = cityDataDelegate;

    NSString *urlString = @"http://gifucities.appspot.com/json/data";
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[NSURLConnection connectionWithRequest:req delegate:self];
}

- (NSArray *)areaList
{
    //return root;

    NSMutableArray *areas = [[[NSMutableArray alloc] init] autorelease];

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];

        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Area"];
        while ([rs next]) {
            [areas addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs intForColumn:@"area_id"]], @"area_id",
                              [rs stringForColumn:@"name"], @"name",
                              nil]];
        }
        [rs close];  

        [db close];
    } else {
        NSLog(@"Could not open db.");
    }
    //NSLog(@"areaList: %@", areas);
    return areas;
}

- (NSString *)areaName:(int)areaId
{
    NSString *name = nil;

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        
        FMResultSet *rs = [db executeQuery:@"SELECT name FROM Area WHERE area_id = ?", [NSNumber numberWithInt:areaId]];
        while ([rs next]) {
            name = [rs stringForColumn:@"name"];
            break;
        }
        [rs close];  
        
        [db close];
    } else {
        NSLog(@"Could not open db.");
    }
    //NSLog(@"areaName: %@", name);
    return name;
}

- (int)areaMaxId:(FMDatabase *)db
{
    int maxId = 0;

    FMResultSet *rs = [db executeQuery:@"SELECT MAX(area_id) FROM Area"];
    while ([rs next]) {
        maxId = [rs intForColumnIndex:0];
        break;
    }
    [rs close];  

    //NSLog(@"areaMaxId: %d", maxId);
    return maxId;
}

- (NSArray *)cityList:(int)areaId sortingByPopulation:(BOOL)population
{
    NSMutableArray *cities = [[[NSMutableArray alloc] init] autorelease];

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];

        FMResultSet *rs;
        if (population) {
            rs = [db executeQuery:@"SELECT * FROM City WHERE area_id = ? ORDER BY population DESC", [NSNumber numberWithInt:areaId]];
        } else {
            rs = [db executeQuery:@"SELECT * FROM City WHERE area_id = ? ORDER BY kana ASC", [NSNumber numberWithInt:areaId]];
        }
        while ([rs next]) {
            [cities addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:[rs intForColumn:@"city_id"]], @"city_id",
                               [NSNumber numberWithInt:[rs intForColumn:@"area_id"]], @"area_id",
                               [rs stringForColumn:@"name"], @"name",
                               [rs stringForColumn:@"kana"], @"kana",
                               [NSNumber numberWithInt:[rs intForColumn:@"population"]], @"population",
                               [rs stringForColumn:@"explanation"], @"explanation",
                               [rs stringForColumn:@"logo"], @"logo",
                               [rs stringForColumn:@"url"], @"url",
                               [NSNumber numberWithDouble:[rs doubleForColumn:@"latitude"]], @"latitude",
                               [NSNumber numberWithDouble:[rs doubleForColumn:@"longitude"]], @"longitude",
                               nil]];
        }
        [rs close];  

        [db close];
    } else {
        NSLog(@"Could not open db.");
    }
    //NSLog(@"cityList: %@", cities);
    return cities;
}

//- (NSArray *)cityList:(NSString *)areaName
//{
//    for (NSDictionary *area in root) {
//        if ([[area objectForKey:@"name"] isEqual:areaName]) {
//            return [area objectForKey:@"cities"];
//        }
//    }
//    return nil;
//}
//
//- (NSArray *)sortCityList:(NSArray *)cityList sortingByPopulation:(BOOL)population
//{
//    return [cityList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
//        if (population) {
//            return [[obj2 objectForKey:@"population"] compare:[obj1 objectForKey:@"population"]]; //人口：降順
//        } else {
//            return [[obj1 objectForKey:@"kana"] compare:[obj2 objectForKey:@"kana"]]; //読み：昇順
//        }
//    }];
//}

- (NSDictionary *)city:(int)cityId
{
    //for (NSDictionary *area in root) {
    //    for (NSDictionary *city in [area objectForKey:@"cities"]) {
    //        if ([[city objectForKey:@"name"] isEqual:cityName]) {
    //            return city;
    //        }
    //    }
    //}
    //return nil;

    NSDictionary *city = nil;

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];

        FMResultSet *rs = [db executeQuery:@"SELECT * FROM City WHERE city_id = ?", [NSNumber numberWithInt:cityId]];
        while ([rs next]) {
            city = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:[rs intForColumn:@"city_id"]], @"city_id",
                    [NSNumber numberWithInt:[rs intForColumn:@"area_id"]], @"area_id",
                    [rs stringForColumn:@"name"], @"name",
                    [rs stringForColumn:@"kana"], @"kana",
                    [NSNumber numberWithInt:[rs intForColumn:@"population"]], @"population",
                    [rs stringForColumn:@"explanation"], @"explanation",
                    [rs stringForColumn:@"logo"], @"logo",
                    [rs stringForColumn:@"url"], @"url",
                    [NSNumber numberWithDouble:[rs doubleForColumn:@"latitude"]], @"latitude",
                    [NSNumber numberWithDouble:[rs doubleForColumn:@"longitude"]], @"longitude",
                    nil];
            break;
        }
        [rs close];  

        [db close];
    } else {
        NSLog(@"Could not open db.");
    }
    //NSLog(@"city: %@", city);
    return city;
}

- (int)cityMaxId:(FMDatabase *)db
{
    int maxId = 0;
    
    FMResultSet *rs = [db executeQuery:@"SELECT MAX(city_id) FROM City"];
    while ([rs next]) {
        maxId = [rs intForColumnIndex:0];
        break;
    }
    [rs close];  

    //NSLog(@"cityMaxId: %d", maxId);
    return maxId;
}

//--------------------------------------------------------------//
#pragma mark -- Cache methods --
//--------------------------------------------------------------//

- (UIImage *)imageForURLString:(NSString *)URLString
{
    return [imageCache_ valueForKey:URLString];
}

- (void)cacheImage:(UIImage *)image forURLString:(NSString *)URLString
{
    [imageCache_ setObject:image forKey:URLString];
}

//--------------------------------------------------------------//
#pragma mark -- NSURLConnection delegate --
//--------------------------------------------------------------//

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receiveData
{
    [self.data appendData:receiveData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *jsonString = [[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] autorelease];
    //self.root = [jsonString JSONValue];

    //add DataBase
    NSArray *areaList = [[NSArray alloc] init]; //[jsonString JSONValue];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        [db beginTransaction];

        for (NSDictionary *area in areaList) {
            int areaId = [self areaMaxId:db] + 1;

            [db executeUpdate:@"INSERT INTO Area (area_id, name) VALUES (?, ?)",
             [NSNumber numberWithInt:areaId],
             [area objectForKey:@"name"]];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }

            for (NSDictionary *city in [area objectForKey:@"cities"]) {
                int cityId = [self cityMaxId:db] + 1;
                
                [db executeUpdate:@"INSERT INTO City "
                 @"(city_id, area_id, name, kana, population, explanation, logo, url, latitude, longitude) "
                 @"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                 [NSNumber numberWithInt:cityId],
                 [NSNumber numberWithInt:areaId],
                 [city objectForKey:@"name"],
                 [city objectForKey:@"kana"],
                 [city objectForKey:@"population"],
                 [city objectForKey:@"explanation"],
                 [city objectForKey:@"logo"],
                 [city objectForKey:@"url"],
                 [city objectForKey:@"latitude"],
                 [city objectForKey:@"longitude"]];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
            }
        }

        [db commit];
        [db close];
    } else {
        NSLog(@"Could not open db.");
    }

    self.data = nil;

    if ([self.delegate respondsToSelector:@selector(cityDataDidFinishLoad:)]) {
        [self.delegate cityDataDidFinishLoad:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.data = nil;
}

//--------------------------------------------------------------//
#pragma mark -- Singleton --
//--------------------------------------------------------------//

+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (!_sharedCityData) {
            _sharedCityData = [super allocWithZone:zone];
            return _sharedCityData;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (void)release
{
}

- (id)autorelease
{
    return self;
}

@end
