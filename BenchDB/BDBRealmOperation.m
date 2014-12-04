//
//  BDBRealmOperation.m
//  BenchDB
//
//  Created by admin on 2014/12/04.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import "BDBRealmOperation.h"
#import "BDBPet.h"

@interface BDBRealmOperation ()

@property (nonatomic, strong) RLMRealm *rm;

@end


@implementation BDBRealmOperation

- (instancetype)init {
	if ((self = [super init])) {
		self.rm = [RLMRealm defaultRealm];
		[[RLMRealm defaultRealm] transactionWithBlock:^{
			[[RLMRealm defaultRealm] deleteAllObjects];
		}];
	}
	return self;
}

- (void)beginTransaction {
	if (self.inMainThread) {
		[self.rm beginWriteTransaction];
		return;
	}
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.rm beginWriteTransaction];
		dispatch_semaphore_signal(semaphore);
	});
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)commitTransaction {
	if (self.inMainThread) {
		[self.rm commitWriteTransaction];
		return;
	}
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.rm commitWriteTransaction];
		dispatch_semaphore_signal(semaphore);
	});
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)insertWithName:(NSString *)name profile:(NSString *)profile created:(NSDate *)created {
	if (self.inMainThread) {
		BDBPet *pet = [[BDBPet alloc] init];
		
		pet.name =  name;
		pet.profile = profile;
		pet.created = created;
		
		if (self.innerTransaction) {
			[self.rm transactionWithBlock:^{
				[self.rm addObject:pet];
			}];
		} else {
			[self.rm addObject:pet];
		}
		return;
	}
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_async(dispatch_get_main_queue(), ^{
		BDBPet *pet = [[BDBPet alloc] init];
		
		pet.name =  name;
		pet.profile = profile;
		pet.created = created;
		
		if (self.innerTransaction) {
			[self.rm transactionWithBlock:^{
				[self.rm addObject:pet];
			}];
		} else {
			[self.rm addObject:pet];
		}
		dispatch_semaphore_signal(semaphore);
	});
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
