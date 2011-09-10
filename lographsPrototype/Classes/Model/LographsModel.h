//
//  LographsModel.h
//  lographsPrototype
//
//  Created by プー坊 on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    LographsItemTypeNormal = 1,
    LographsItemTypeStar,
} LographsItemType;

@interface LographsModel : NSObject {
    NSString *dbPath_;
}

+ (LographsModel *)sharedLographsModel;

- (NSArray *)entryList;
- (void)addEntry:(int)itemId amount:(double)amount;

@end
