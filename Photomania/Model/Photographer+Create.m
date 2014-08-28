//
//  Photographer+Create.m
//  Photomania
//
//  Created by Neo on 8/28/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context {
	Photographer *photographer = nil;

    if (name.length) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTOGRAPHER];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];

        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];

        if (!matches || matches.count > 1) {
            // Error handling
        }
        else if (matches.count) {
            photographer = [matches firstObject];
        }
        else {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME_PHOTOGRAPHER inManagedObjectContext:context];
            photographer.name = name;
        }
    }

    return photographer;
}


@end
