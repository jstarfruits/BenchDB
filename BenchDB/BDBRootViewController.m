//
//  BDBRootViewController.m
//  BenchDB
//
//  Created by admin on 2014/12/03.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import "BDBRootViewController.h"

#define BENCHMARK_START	NSDate *bench_to; NSDate *bench_from = [NSDate new]; NSLog(@"benchstart");
#define BENCHMARK_PRINT bench_to = [NSDate new]; NSLog(@"benched %f Line %d in %@", [bench_to timeIntervalSinceDate:bench_from], __LINE__, [[self class] description]); bench_from = [NSDate new];

@interface BDBRootViewController ()

// Nyaru
@property (nonatomic, strong) NyaruCollection *col;

// FMDB
@property (nonatomic, strong) FMDatabaseQueue *queue;

// Realm
@property (nonatomic, strong) RLMRealm *rm;

@property (nonatomic, strong) NSOperationQueue *opq;

@property (weak, nonatomic) IBOutlet UIProgressView *progress1;
@property (weak, nonatomic) IBOutlet UIProgressView *progress2;
@property (weak, nonatomic) IBOutlet UIProgressView *progress3;

@property (weak, nonatomic) IBOutlet UISwitch *transactionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mainThreadSwitch;

@end

@implementation BDBRootViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.progress1.progress = 0;
	self.progress2.progress = 0;
	self.progress3.progress = 0;
	
	self.opq = [[NSOperationQueue alloc] init];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)_start:(id)sender {
	[self _startWithType:BDBTypeFMDB];
	[self _startWithType:BDBTypeNyaru];
	[self _startWithType:BDBTypeRealm];
}

- (void)_curNum:(NSInteger)num {
	self.title = [NSString stringWithFormat:@"%ld", (long)num];
}
- (void)_startWithType:(BDBType)type {
	BDBOperation *op;
	UIProgressView *pv;
	switch (type) {
		case BDBTypeNyaru:
			pv = self.progress2;
			op = [[BDBNyaruDBOperation alloc] init];
			
			break;
			
		case BDBTypeRealm: {
			pv = self.progress3;
			op = [[BDBRealmOperation alloc] init];
			
			break;
		}
			
		default: // BDBTypeFMDB
			pv = self.progress1;
			op = [[BDBFMDBOperation alloc] init];
			break;
	}
	
	op.innerTransaction = self.transactionSwitch.on;
	op.inMainThread = self.mainThreadSwitch.on;
	
	if (op.inMainThread) {
		op.num = 10000;
		
		[self _curNum:op.num];
		
		BENCHMARK_START;
		[op start];
		BENCHMARK_PRINT;
		return;
	}
	
	op.num = 5000;
	[self _curNum:op.num];
	
	[op setProgressHandler:^(float progress) {
		pv.progress = progress;
	}];
	[op setCompletionBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[pv setProgress:1.0f animated:YES];
		});
	}];
	
	[self.opq addOperation:op];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self _startWithType:indexPath.row];
}

@end
