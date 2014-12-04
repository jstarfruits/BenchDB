//
//  BDBOperation.m
//  BenchDB
//
//  Created by admin on 2014/12/04.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import "BDBOperation.h"

@interface BDBOperation () {
	BOOL _isFinished;
	BOOL _isExecuting;
}

@end

@implementation BDBOperation

- (BOOL)isConcurrent {
	return !self.inMainThread;
}

- (BOOL)isExecuting {
	return _isExecuting;
}

- (BOOL)isFinished {
	return _isFinished;
}

- (void)beginTransaction {
}

- (void)commitTransaction {
}

- (void)start {
	
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	_isExecuting = YES;
	_isFinished = NO;
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
	
	CGFloat limit = self.num;
	
	NSDate *start = [NSDate date];
	
	if (!self.innerTransaction) {
		[self beginTransaction];
	}
	
	for (CGFloat i = 0; i < limit; i++) {
		
		NSInteger num = arc4random() % 3000;
		NSDate *date = [NSDate date];
		NSString *profile = @"lorem ipsum（ロレム・イプサム、略してリプサム lipsum ともいう）とは、出版、ウェブデザイン、グラフィックデザインなどの諸分野において使用されている典型的なダミーテキスト。書籍やウェブページや広告などのデザインのプロトタイプを制作したり顧客に";
		NSString *name = [NSString stringWithFormat:@"ぽち%ld号", (long)num];
		
		[self insertWithName:name profile:profile created:date];
		
		if (self.inMainThread) {
			if ((int)i % 100 == 0) {
				NSLog(@"%f", -[start timeIntervalSinceNow]);
			}
			continue;
		}
		
		if ((int)i % 10 == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				CGFloat progress = (i / limit) * 0.95;
				if (self.progressHandler != nil) {
					self.progressHandler(progress);
				}
				NSLog(@"%f", -[start timeIntervalSinceNow]);
			});
		}
		
		if (self.isCancelled) {
			break;
		}
	}
	
	if (!self.innerTransaction) {
		[self commitTransaction];
	}
	
	if (self.inMainThread) {
		NSLog(@"complete --- %f", -[start timeIntervalSinceNow]);
		[self willChangeValueForKey:@"isExecuting"];
		[self willChangeValueForKey:@"isFinished"];
		_isExecuting = NO;
		if (!self.isCancelled) {
			_isFinished = YES;
		}
		[self didChangeValueForKey:@"isExecuting"];
		[self didChangeValueForKey:@"isFinished"];
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@"complete --- %f", -[start timeIntervalSinceNow]);
		[self willChangeValueForKey:@"isExecuting"];
		[self willChangeValueForKey:@"isFinished"];
		_isExecuting = NO;
		if (!self.isCancelled) {
			_isFinished = YES;
		}
		[self didChangeValueForKey:@"isExecuting"];
		[self didChangeValueForKey:@"isFinished"];
	});
}

- (void)insert {
}
- (void)insertWithName:(NSString *)name profile:(NSString *)profile created:(NSDate *)created {
}

@end
