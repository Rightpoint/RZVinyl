//
//  RZPersonLoader.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonLoader.h"
#import "RZPerson.h"

static NSString* kRZPersonDataFileName = @"person_data.json";

@interface RZPersonLoader ()

@property (nonatomic, strong, readonly) NSArray *rawPeople;
@property (nonatomic, assign) NSUInteger offset;

@end

@implementation RZPersonLoader

- (void)loadPeopleWithBatchSize:(NSUInteger)batchSize completion:(void (^)(NSError *))completion
{
    if ( self.offset >= self.rawPeople.count ) {
        NSLog(@"No more people to load");
        if ( completion ) {
            completion(nil);
        }
        return;
    }
    
    [[RZCoreDataStack defaultStack] performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
       
        NSRange importRange = NSMakeRange(self.offset, MIN(batchSize, self.rawPeople.count - self.offset) );
        NSArray *peopleInRange = [self.rawPeople subarrayWithRange:importRange];
        
        NSArray *importedPeople = [RZPerson rzi_objectsFromArray:peopleInRange inContext:context];
        [importedPeople enumerateObjectsUsingBlock:^(RZPerson *person, NSUInteger idx, BOOL *stop) {
            person.sortIndex = @(importRange.location + idx);
        }];
        
        self.offset += batchSize;
        
    } completion:completion];
}

- (NSArray *)rawPeople
{
    // Generally not a good idea to do this in a real app.
    // This data will live in memory forever.
    static NSArray *s_rawPeople = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *peopleDataURL = [[NSBundle mainBundle] URLForResource:kRZPersonDataFileName withExtension:nil];
        NSData *peopleData = [NSData dataWithContentsOfURL:peopleDataURL];
        NSError *err = nil;
        s_rawPeople = [NSJSONSerialization JSONObjectWithData:peopleData options:kNilOptions error:&err];
        NSAssert(err == nil, @"Error importing person data from JSON: %@", err);
    });
    return s_rawPeople;
}

@end
