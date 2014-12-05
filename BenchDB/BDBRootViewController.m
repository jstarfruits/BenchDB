//
//  BDBRootViewController.m
//  BenchDB
//
//  Created by admin on 2014/12/03.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import "BDBRootViewController.h"

@interface BDBRootViewController ()

@property (nonatomic, strong) NSOperationQueue *opq;

@property (weak, nonatomic) IBOutlet UIProgressView *progress1;
@property (weak, nonatomic) IBOutlet UIProgressView *progress2;
@property (weak, nonatomic) IBOutlet UIProgressView *progress3;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel3;

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
	UILabel *label;
	switch (type) {
		case BDBTypeNyaru:
			pv = self.progress2;
			op = [[BDBNyaruDBOperation alloc] init];
			label = self.timeLabel2;
			
			break;
			
		case BDBTypeRealm: {
			pv = self.progress3;
			op = [[BDBRealmOperation alloc] init];
			label = self.timeLabel3;
			
			break;
		}
			
		default: // BDBTypeFMDB
			pv = self.progress1;
			op = [[BDBFMDBOperation alloc] init];
			label = self.timeLabel1;
			break;
	}
	
	op.innerTransaction = self.transactionSwitch.on;
	op.inMainThread = self.mainThreadSwitch.on;
	
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	fmt.dateFormat = @"mm:ss.SSS";
	pv.progress = 0.0f;
	
	NSDate *start = [NSDate date];
	label.text = @"0";
	
	if (op.inMainThread) {
		op.num = 10000;
		
		[self _curNum:op.num];
		
		[op start];
		
		[pv setProgress:1.0f animated:NO];
		NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate:-start.timeIntervalSinceNow];
		label.text = [fmt stringFromDate:d];
		return;
	}
	
	op.num = 5000;
	[self _curNum:op.num];
	
	[op setProgressHandler:^(float progress) {
		pv.progress = progress;
		NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate:-start.timeIntervalSinceNow];
		label.text = [fmt stringFromDate:d];
	}];
	[op setCompletionBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[pv setProgress:1.0f animated:YES];
			NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate:-start.timeIntervalSinceNow];
			label.text = [fmt stringFromDate:d];
		});
	}];
	
	[self.opq addOperation:op];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self _startWithType:indexPath.row];
}

@end
