//
//  BDBRootViewController.h
//  BenchDB
//
//  Created by admin on 2014/12/03.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDBPet.h"
#import <NyaruDB/NyaruDB.h>
#import <FMDB/FMDB.h>
#import "BDBRealmOperation.h"
#import "BDBFMDBOperation.h"
#import "BDBNyaruDBOperation.h"

@interface BDBRootViewController : UITableViewController

@property (nonatomic, assign) BDBType type;

@end
