//
//  BDBFMDBOperation.m
//  BenchDB
//
//  Created by admin on 2014/12/04.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import "BDBFMDBOperation.h"
#import <FMDB/FMDB.h>

@interface BDBFMDBOperation () {
}

@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) FMDatabase *db;

@end

@implementation BDBFMDBOperation

- (instancetype)init {
	if ((self = [super init])) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *path = paths.firstObject;
		self.queue = [FMDatabaseQueue databaseQueueWithPath:[path stringByAppendingPathComponent:@"fmdb.db"]];
		__weak typeof(self) ws = self;
		[self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
			ws.db = db;
			[db executeUpdate:@"CREATE TABLE IF NOT EXISTS main (name TEXT, profile TEXT, created REAL)"];
			[db executeUpdate:@"PRAGMA auto_vacuum = 1"];
		}];
		[self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
			[db executeUpdate:@"DELETE FROM main;"];
		}];
	}
	return self;
}

- (void)beginTransaction {
	
}
- (void)commitTransaction {
}

- (void)start {
	if (self.innerTransaction) {
		[super start];
	} else {
		[_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
			[super start];
		}];
	}
}

- (void)insertWithName:(NSString *)name profile:(NSString *)profile created:(NSDate *)created {
	if (self.innerTransaction) {
		[self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
			[db executeUpdate:@"INSERT INTO main (name, profile, created) VALUES (?, ?, ?);",
			 name, profile, created];
		}];
	} else {
		[self.db executeUpdate:@"INSERT INTO main (name, profile, created) VALUES (?, ?, ?);",
		 name, profile, created];
	}
}

@end
