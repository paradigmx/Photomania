//
//  Photographer+Create.m
//  Photomania
//
//  Created by Neo Lee on 8/31/14.
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
        NSArray *result = [context executeFetchRequest:request error:&error];
        
        if (!result || result.count > 1) {
            // Error handling
        }
        else if (result.count) {
            photographer = [result firstObject];
        }
        else {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME_PHOTOGRAPHER
                                                         inManagedObjectContext:context];
            photographer.name = name;
        }
    }
    
    return photographer;
}

+ (Photographer *)userInManagedObjectContext:(NSManagedObjectContext *)context {
	return [self photographerWithName:@" My Photos" inManagedObjectContext:context];
}

- (BOOL)isUser {
	return self == [[self class] userInManagedObjectContext:self.managedObjectContext];
}

@end
