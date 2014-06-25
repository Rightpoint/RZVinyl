RZVinyl
=======

[![Build Status](https://travis-ci.org/Raizlabs/RZVinyl.svg)](https://travis-ci.org/Raizlabs/RZVinyl)

Stack management, ActiveRecord utilities, and seamless importing for CoreData.

===

# Installation

### CocoaPods (Recommended)

Add the following to your Podfile:

```
pod RZVinyl, '~> 0.1'
```

To exclude RZAutoImport extensions, use the `Core` subspec: 

```
pod RZVinyl/Core, '~> 0.1'
```

RZVinyl follows semantic versioning conventions. As newer versions are released, you will need to update the version spec in your Podfile as necessary. See the [release history](https://github.com/Raizlabs/RZVinyl/releases) for version information and release notes.

### Manual Installation

##### Without Import Extensions

Simply copy/add the contents of `Classes/` into your project and ensure that you are linking with CoreData. **Do not** copy the contents of `Extensions/`.

##### With Import Extensions

Because of the optional RZAutoImport extensions, which depend on the RZAutoImport library, manual installation is a bit more difficult. Hence why CocoaPods is the recommended installation method.

To install manually with RZAutoImport extensions:

1. Follow the steps for installing without import extensions.
2. Also copy the contents of `Extensions/` into your project.
3. Install [RZAutoImport](https://github.com/Raizlabs/RZAutoImport) in your project.
4. Add the following to your build configuration's compiler flags:
```
-DRZV_IMPORT_AVAILABLE=1
```

If all went well, your project should build cleanly and the methods from `NSManagedObject+RZAutoImport.h` should be available.

# Demo Project

A demo project is available in the `Example` directory. The demo project uses CocoaPods, and can be opened from a temporary directory by running 

```
pod try RZVinyl
```

Alternatively, the demo can be configured by running the following commands from the root project directory.

```
cd Example
pod install
```

Then, open `RZVinylDemo.xcworkspace` and check out the demo!


**Note: The above steps assume that the CocoaPods gem is installed.**

If you do not have CocoaPods installed, follow the instructions [here](http://cocoapods.org/).

# Overview

To use RZVinyl, first add `#import "RZVinyl.h"` to any classes that will need to use it, or to your app's `.pch` file. RZVinyl can be broken down into three basic areas of functionality, as follows.

## RZCoreDataStack

`RZCoreDataStack` is a class for building and managing CoreData stacks, including the model, managed object context, and persistent store coordinator. It has convenience methods for performing concurrent background operations with a separate managed object context, as well as a set of class methods for making a default stack available via the singleton pattern.

##### Create a new stack

```objective-c
// Default configuration, default store URL (in Library directory), no extra options
RZCoreDataStack *myStack = [[RZCoreDataStack alloc] initWithModelName:@"MyModel"
                                                        configuration:nil
                                                            storeType:NSInMemoryStoreType
                                                             storeURL:nil
                                                              options:kNilOptions];
```

##### Perform a concurrent operation

```objective-c
[myStack performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
	// do some stuff with the context
	// this block is on a background thread and the context has private-queue confinement
} completion:^(NSError *err) {
	// save to the persistent store
	// this block is on the main thread
	if ( !err ) {
		[myStack save:YES];
	}
}];
```

##### Purge stale objects from the store

Each managed object subclass can provide a "stale" predicate that will be used here to delete all objects which pass the predicate. This is useful for cleaning up stale or orphaned objects. This can also be invoked every time the app enters the background if you initialize the stack with the `RZCoreDataStackOptionsEnableAutoStalePurge` option.

```objective-c
[myStack purgeStaleObjectsWithCompletion:^(NSError *err){
	// This is on the main thread
	if ( !err ) {
		NSLog(@"Purged!");
	}
}];
```

##### Create a background (private queue) context

```objective-c
// This context is a child of the disk writer context and a sibling of the main thread context. 
// Saving it will automatically merge changes into the main context.
NSManagedObjectContext *backgroundContext = [myStack backgroundManagedObjectContext];
```

##### Create a temporary main-thread context

```objective-c
// This context is a child of the primary main thread context. 
// It is useful for creating a "sandbox" for temporary edits that may or may not be saved.
// Its objects can safely be used on the main thread (e.g. with UI elements).
// Saving it will automatically push changes up to the primary main thread context.
NSManagedObjectContext *scratchContext = [myStack temporaryManagedObjectContext];
```

## RZVinylRecord

`RZVinylRecord` is a category on `NSManagedObject` which provides a partial implementation of the Active Record pattern. Each method in `NSManagedObject+RZVinylRecord` has two signatures - one which accepts a managed object context parameter, and one which uses the main managed object context from the default `RZCoreDataStack`. 

```objective-c
// Delete all objects of receiver's type in default stack's main context
+ (void)rzv_deleteAll;

// Delete all objects of receiver's type in the provided context
+ (void)rzv_deleteAllInContext:(NSManagedObjectContext *)context;
```

The no-context versions may only be used from the main thread, or an exception will be thrown. Similarly, if no default stack has been set, attempting to call one of these methods without providing a context will also throw an exception.

### Creating/Updating

##### Create a new empty instance

```objective-c
// Inserted into the default main context
MyManagedObject *newObject = [MyManagedObject rzv_newObject];

// Inserted into the provided context
MyManagedObject *newObject = [MyManagedObject rzv_newObjectInContext:context];
```

##### Retrieve or create an instance for a primary key value

These methods use the attribute provided by overriding `+ (NSString *)rzv_primaryKey;` in the managed object subclass to search for an existing object with the provided value for that attribute, optionally creating a new object and initializing it with the primary key value if one was not found.

```objective-c
// In the default main context
MyManagedObject *existingObjectOrNil = [MyManagedObject rzv_objectWithPrimaryKeyValue:@(12345) createNew:NO];

// In the provided context, creating a new instance if one isn't found
MyManagedObject *existingObjectOrNil = [MyManagedObject rzv_objectWithPrimaryKeyValue:@(12345) createNew:YES inContext:context];

```

You can also find/create objects based on a set of other attributes. If `createNew` is YES and a match isn't found, a new instance will be created and initialized with the provided attribute dictionary.

```objective-c
// In the default main context
MyManagedObject *existingObjectOrNil = [MyManagedObject rzv_objectWithAttributes:@{ @"name" : @"Bob Marley" } 
                                                                       createNew:NO];

// In the provided context, creating a new instance if one isn't found
MyManagedObject *existingObjectOrNil = [MyManagedObject rzv_objectWithAttributes:@{ @"name" : @"Bob Marley" }
                                                                       createNew:YES
                                                                       inContext:context];

```

### Fetching

##### Fetch all objects

```objective-c
// In the default main context
NSArray *allMyObjects = [MyManagedObject rzv_all];

// In the provided context
NSArray *allMyObjects = [MyManagedObject rzv_allInContext:context];

```

##### Fetch objects matching a predicate

```objective-c
// In the default main context
NSArray *matchingObjects = [MyManagedObject rzv_where:RZVPred(@"someAttribute >= 18")];

// In the provided context
NSArray *matchingObjects = [MyManagedObject rzv_where:RZVPred(@"someAttribute >= 18") inContext:context];
```

The "where" methods also have versions that take sort descriptors to sort the results.

##### Get the count of objects

```objective-c
// In the default main context
NSUInteger theCount = [MyManagedObject rzv_count];

// In the provided context, with a predicate
NSUInteger theCount = [MyManagedObject rzv_countWhere:RZVPred(@"someAttribute >= %@", minimum) 
                                            inContext:context];
```

### Deleting

##### Delete a single object

```objective-c
// Uses the object's context
[myObjectInstance rzv_delete];
```

##### Delete all objects of receiver's type

```objective-c
// In the default main context
[MyManagedObject rzv_deleteAll];

// In the provided context, with a predicate
[MyManagedObject rzv_deleteAllWhere:RZVPred(@"someAttribute == nil") inContext:context];
```

### Saving

The semantics of saving an object in CoreData are rather different from what might be expected when using the Active Record pattern, particularly when dealing with a more complex context hierarchy, as in `RZCoreDataStack`. In order to persist changes to the persistent store, it is necessary to save the entire context tree all the way to its root, which also saves any other changes in any of the contexts along the way. To avoid unintended, non-obvious consequences, no "save" methods are provided for managed object classes via `RZVinylRecord`, and saving must be handled via managed object contexts and/or the CoreData stack.

To persist changes to objects in the main context, simply call `save:` on the `RZCoreDataStack`. This will save both the main context as well as the disk write context. If you are using a background or temporary context, you must save that context first before calling `save:` on the stack. Saving either of these separate contexts will automatically merge changes into the main context.

## RZImport Extensions

[RZImport](https://github.com/Raizlabs/RZImport) can be combined with RZVinyl for powerful automatic importing of managed objects from deserialized JSON or any other plain-ol-data `NSDictionary` or `NSArray` source.

`NSManagedObject+RZImport` provides a partial implementation of the `RZImportable` protocol that automatically handles object uniquing and relationship imports. For a working demo, see the example project.

### Usage

To enable RZImport for your managed object subclasses, create a category and override the following methods from `NSManagedObject+RZVinyl` and `NSManagedObject+RZImportableSubclass`:

##### `+ (NSString *)rzv_primaryKey;`

Override to return the name of the property attributes representing the "unique ID" of this object type

##### `+ (NSString *)rzv_externalPrimaryKey;`

If the key in the dictionary representations of this object is different from the primary key property name, override this method to return that key here. If not overridden, the same value returned by `rzv_primaryKey` will be used to find unique instances of the object.

You can also implement the methods of `RZImportable` in your managed object classes to handle validation, provide further custom key/property mappings, etc, with two important caveats:

##### Do not override `+ (id)rzi_existingObjectForDict:(NSDictionary *)dict`

This is implemented by the `NSManagedObject+RZImport` category to handle CoreData concurrency, and internally calls the extended version with a context parameter:

```objective-c
+ (id)rzi_existingObjectForDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
```

The implementation provided by the category automatically manages unique objects during an import by finding an existing object matching the dictionary being imported. This default implementation is safe to override as long as you always return the value provided by `super` in the cases that your override does not handle.

##### Do not override `- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key`

This is for similar reasons as above - the category implements the protocol method and internally calls the extended version with a context parameter:

```objective-c
- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context;
```

The category implementation handles recursive imports for keys representing relationships. You can override the extended method in a subclass as well, as long as you return the result of invoking the `super` implementation for keys that your override does not handle. See below for an example.

### Example

Here is an example of a managed object subclass that is configured for usage with `RZImport`.

```objective-c
// RZArtist.h
@interface RZArtist : NSManagedObject

@property (nonatomic, retain) NSNumber *remoteID;
@property (nonatomic, retain) NSDate *birthdate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *rating;

@property (nonatomic, retain) RZGenre *genre; 	// one-to-one relationship
@property (nonatomic, retain) NSSet *songs; 	// one-to-many relationship of 'RZSong' objects

@end


// RZArtist+RZImport.h
@interface RZArtist (RZImport) <RZImportable>

@end


// RZArtist+RZImport.m
@implementation RZArtist (RZImport)

+ (NSString *)rzv_primaryKey
{
    return @"remoteID";
}

+ (NSString *)rzv_externalPrimaryKey
{
	return @"id";
}

+ (NSDictionary *)rzi_customMappings
{
	return @{ @"dob" : @"birthdate" };
}

+ (NSString *)rzi_dateFormatForKey:(NSString *)key
{
	if ( [key isEqualToString:@"dob"] ) {
		return @"yyyy-MM-dd";
	}
	return nil;
}

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context
{
	// Genre string will be imported as a managed object (RZGenre)
	if ( [key isEqualToString:@"genre"] ) {
		// Could also use an NSValueTransformer if this will be done in multiple classes
		if ( [value isKindOfClass:[NSString class]] ) {
			self.genre = [RZGenre rzv_objectWithAttributes:@{ @"name" : value }
							                     createNew:YES
							                     inContext:context];
		}
		return NO;
	}
	return [super rzi_shouldImportValue:value forKey:key inContext:context];
}

@end
```

Using this basic implementation and assuming `RZSong` and `RZGenre` are also configured correctly, you can do the following:

```objective-c
// This could just as easily be deserialized JSON
NSDictionary *artistDict = @{
	@"id" : @100,
	@"dob" : @"1942-11-27", 	    // string -> date, via provided format
	@"rating" : @"4.7", 		    // string -> number, automatically
	@"name" : @"Jimi Hendrix",
	@"genre" : @"Psychedelic Rock", // string -> RZGenre, via protocol method
	@"songs" : @[			        // array -> RZSong to-many relationship, automatically 
		@{
			@"id" : @1000,
			@"title" : @"Hey Joe"
	   	},
	   	@{
	   		@"id" : @1001,
	   		@"title" : @"Spanish Castle Magic"
	   	}
	]
};

[[RZCoreDataStack defaultStack] performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
	
	// Import jimi and his nested songs from the dictionary
	RZArtist *jimi = [RZArtist rzi_objectFromDictionary:artistDict inContext:context];

} completion:^(NSError *err) {
	if ( !err ) {
		[myStack save:YES];
	}
	
	// Fetch the record from the main thread
	RZArtist *mainThreadJimi = [RZArtist rzv_objectWithPrimaryKeyValue:@100];
}];

```

# Full Documentation

For more comprehensive documentation, see the (TODO) generated from the AppleDoc header comments.

# License

RZVinyl is licensed under the MIT license. See LICENSE for details.
