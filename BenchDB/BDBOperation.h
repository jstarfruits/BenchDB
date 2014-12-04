//
//  BDBOperation.h
//  BenchDB
//
//  Created by admin on 2014/12/04.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BDBType) {
	BDBTypeFMDB,
	BDBTypeNyaru,
	BDBTypeRealm,
	BDBTypeFMDBOuter,
	BDBTypeRealmOuter,
};

@interface BDBOperation : NSOperation

@property (copy) void (^progressHandler)(float progress);
@property (nonatomic, assign) BOOL innerTransaction;
@property (nonatomic, assign) BOOL inMainThread;

@property (nonatomic, assign) NSInteger num;

- (void)insertWithName:(NSString *)name profile:(NSString *)profile created:(NSDate *)created;
- (void)beginTransaction;
- (void)commitTransaction;

@end
