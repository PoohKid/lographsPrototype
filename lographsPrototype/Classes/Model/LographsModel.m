//
//  LographsModel.m
//  lographsPrototype
//
//  Created by プー坊 on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LographsModel.h"
#import "FMDatabase.h"
#import "NSDictionary+Null.h"


static LographsModel *sharedLographsModel_ = nil;

@implementation LographsModel

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

+ (LographsModel *)sharedLographsModel
{
    @synchronized(self) {
        if (!sharedLographsModel_) {
            sharedLographsModel_ = [[self alloc] init];
        }
    }
    return sharedLographsModel_;
}

- (id)init{
    self = [super init];

    if (!self) {
        return nil;
    }

    //データベースファイルをリソース（編集不可）からドキュメント（アプリから変更可能）にコピーする
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lographs.db"];

    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dbPath_ = [[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"lographs.db"] retain];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dbPath_] == NO) { //ファイルが無い場合のみコピーする（既にある場合に上書きするとデータが消えてしまうので）
        NSError *error;
        if ([fileManager copyItemAtPath:resourcePath toPath:dbPath_ error:&error] == NO) {
            NSLog(@"DB COPY ERROR! %@", [error localizedDescription]);
        }
    }

    return self;
}

- (void)dealloc
{
    [dbPath_ release], dbPath_ = nil;
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- public methods --
//--------------------------------------------------------------//

- (NSArray *)entryList
{
    NSString *selectEntry =
    @"SELECT "
    @"  entry.entry_id, "
    @"  entry.date, "
    @"  entry.amount, "
    @"  item.item_id, "
    @"  item.name, "
    @"  item.categories, "
    @"  item.type, "
    @"  item.unit "
    @"FROM entry, item "
    @"WHERE entry.item_id = item.item_id "
    @"ORDER BY entry.date DESC ";
    //NSLog(@"selectEntry: %@", selectEntry);

    NSMutableArray *entries = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];

    NSMutableDictionary *dateMap = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease]; //日付とリストの関連付け

    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        FMResultSet *rs = [db executeQuery:selectEntry];
        while ([rs next]) {
            NSMutableDictionary *entry = [[NSMutableDictionary alloc] initWithCapacity:10];
            [entry setObjectNull:[NSNumber numberWithInt:[rs intForColumn:@"entry_id"]] forKey:@"entry_id"];
            [entry setObjectNull:[rs dateForColumn:@"date"] forKey:@"date"];
            [entry setObjectNull:[NSNumber numberWithDouble:[rs doubleForColumn:@"amount"]] forKey:@"amount"];
            [entry setObjectNull:[NSNumber numberWithInt:[rs intForColumn:@"item_id"]] forKey:@"item_id"];
            [entry setObjectNull:[rs stringForColumn:@"name"] forKey:@"name"];
            [entry setObjectNull:[rs stringForColumn:@"categories"] forKey:@"categories"];
            [entry setObjectNull:[NSNumber numberWithInt:[rs intForColumn:@"type"]] forKey:@"type"];
            [entry setObjectNull:[rs stringForColumn:@"unit"] forKey:@"unit"];
            //NSLog(@"entry: %@", entry);

            //日付ごとのリストに追加
            NSString *date = [dateFormatter stringFromDate:[entry objectForKeyNull:@"date"]];
            NSMutableArray *entriesOfDate = [dateMap objectForKey:date];
            if (entriesOfDate == nil) {
                entriesOfDate = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
                [dateMap setObject:entriesOfDate forKey:date];
                [entries addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                    date, @"date",
                                    entriesOfDate, @"entriesOfDate",
                                    nil]];
            }
            [entriesOfDate addObject:entry];
        }
        [rs close];
        [db close];
    } else {
        NSLog(@"Could not open db.");
    }

    return entries;
}

- (void)addEntry:(int)itemId amount:(double)amount
{
    NSString *insertEntry =
    @"INSERT INTO entry ( "
    @"  item_id, "
    @"  date, "
    @"  amount "
    @") "
    @"VALUES ( "
    @"  ?, "
    @"  ?, "
    @"  ? "
    @") ";
    NSLog(@"insertEntry: %@", insertEntry);

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        [db beginTransaction];

        NSDate *date = [NSDate date];

        [db executeUpdate:insertEntry,
         [NSNumber numberWithInt:itemId],
         date,
         [NSNumber numberWithDouble:amount]];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }

//        for (NSDictionary *area in areaList) {
//            int areaId = [self areaMaxId:db] + 1;
//            
//            [db executeUpdate:@"INSERT INTO Area (area_id, name) VALUES (?, ?)",
//             [NSNumber numberWithInt:areaId],
//             [area objectForKey:@"name"]];
//            if ([db hadError]) {
//                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
//            }
//            
//            for (NSDictionary *city in [area objectForKey:@"cities"]) {
//                int cityId = [self cityMaxId:db] + 1;
//                
//                [db executeUpdate:@"INSERT INTO City "
//                 @"(city_id, area_id, name, kana, population, explanation, logo, url, latitude, longitude) "
//                 @"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
//                 [NSNumber numberWithInt:cityId],
//                 [NSNumber numberWithInt:areaId],
//                 [city objectForKey:@"name"],
//                 [city objectForKey:@"kana"],
//                 [city objectForKey:@"population"],
//                 [city objectForKey:@"explanation"],
//                 [city objectForKey:@"logo"],
//                 [city objectForKey:@"url"],
//                 [city objectForKey:@"latitude"],
//                 [city objectForKey:@"longitude"]];
//                if ([db hadError]) {
//                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
//                }
//            }
//        }
        
        [db commit];
        [db close];
    } else {
        NSLog(@"Could not open db.");
    }
}

//--------------------------------------------------------------//
#pragma mark -- Singleton --
//--------------------------------------------------------------//

+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (!sharedLographsModel_) {
            sharedLographsModel_ = [super allocWithZone:zone];
            return sharedLographsModel_;
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
