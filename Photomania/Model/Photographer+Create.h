//
//  Photographer+Create.h
//  Photomania
//
//  Created by Neo on 8/28/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "Photographer.h"

#define ENTITY_NAME_PHOTOGRAPHER @"Photographer"

@interface Photographer (Create)
+ (Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
@end
