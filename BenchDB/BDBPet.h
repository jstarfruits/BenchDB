//
//  BDBPet.h
//  BenchDB
//
//  Created by admin on 2014/12/03.
//  Copyright (c) 2014年 Little Gleam. All rights reserved.
//

#import <Realm/Realm.h>

@interface BDBPet : RLMObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *profile;
@property (nonatomic, strong) NSDate *created;

@end
