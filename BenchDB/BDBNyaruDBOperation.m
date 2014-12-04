//
//  BDBNyaruDBOperation.m
//  BenchDB
//
//  Created by admin on 2014/12/04.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import "BDBNyaruDBOperation.h"
#import <NyaruDB/NyaruDB.h>

@interface BDBNyaruDBOperation ()

@property (nonatomic, strong) NyaruCollection *col;

@end

@implementation BDBNyaruDBOperation

- (instancetype)init {
	if ((self = [super init])) {
		self.col = [[NyaruDB instance] collection:@"default"];
		[self.col removeAll];
		[self.col waitForWriting];
	}
	return self;
}

- (void)beginTransaction {
}

- (void)commitTransaction {
	if (!self.innerTransaction) {
		[self.col waitForWriting];
	}
}

- (void)insertWithName:(NSString *)name profile:(NSString *)profile created:(NSDate *)created {
	[self.col put:@{
					@"name" : name,
					@"profile" : profile,
					@"date" : created
					}];
	
	if (self.innerTransaction) {
		[self.col waitForWriting];
	}
}

@end
