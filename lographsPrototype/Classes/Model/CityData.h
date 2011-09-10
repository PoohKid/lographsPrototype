//
//  CityData.h
//  GifuGuide
//
//  Created by admin on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CityDataDelegate;

@interface CityData : NSObject {
    id<CityDataDelegate> delegate;
    NSMutableDictionary *imageCache_;
    NSString *dbPath_;
}

@property (nonatomic, assign) id<CityDataDelegate> delegate;

+ (CityData *)sharedCityData;

- (void)loadCityData:(id<CityDataDelegate>)delegate;

- (NSArray *)areaList;
- (NSString *)areaName:(int)areaId;

- (NSArray *)cityList:(int)areaId sortingByPopulation:(BOOL)population;
//- (NSArray *)cityList:(NSString *)areaName;
//- (NSArray *)sortCityList:(NSArray *)cityList sortingByPopulation:(BOOL)population;
- (NSDictionary *)city:(int)cityId;

- (UIImage *)imageForURLString:(NSString *)URLString;
- (void)cacheImage:(UIImage *)image forURLString:(NSString *)URLString;

@end

@protocol CityDataDelegate <NSObject>

@optional
- (void)cityDataDidFinishLoad:(CityData *)cityData;

@end
