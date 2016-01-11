//
//  RZVinylOptions.h
//  Pods
//
//  Created by Eric Slosser on 11/24/15.
//
//

#import <Foundation/Foundation.h>

@interface RZVinylOptions : NSObject

@property (assign, nonatomic) BOOL logWhenSavedWithoutChanges;  // default NO

+(RZVinylOptions *)sharedOptions;

@end
