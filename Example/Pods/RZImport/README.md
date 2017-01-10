RZImport
============

[![Build Status](https://travis-ci.org/Raizlabs/RZImport.svg)](https://travis-ci.org/Raizlabs/RZImport)

Tired of writing boilerplate to import deserialized API responses to model objects?

Tired of dealing with dozens and dozens of string keys?

RZImport is here to help!

RZImport is a category on `NSObject` and an accompanying optional protocol for creating and updating model objects in your iOS applications. It's particularly useful for importing objects from deserialized JSON HTTP responses in REST API's, but it works with any `NSDictionary` or array of dictionaries that you need to convert to native model objects.

#### Convenient

Property names are inferred from similarly named string keys in an `NSDictionary` and performs automatic type-conversion whenever possible. No need to reference string constants all over the place, just name your properties in a similar way to the keys in the dictionary and let RZImport handle it for you.

RZImport automatically performs case-insensitive matches between property names and key names, ignoring underscores. For example, all of the following keys will map to a property named `firstName`:

- `firstName`
- `FirstName`
- `first_name`
- `FiRst_NAme`


#### Flexible

Can't name your properties the same as the keys in the dictionary? Need to perform extra validation or import logic? No problem! The `RZImportable` protocol has hooks for specifying custom mappings, custom import logic and validation on a per-key basis, and more!

#### Performant

Key/property mappings are created once and cached, so once an object type has been imported once, subsequent imports are super-speedy!

#### Example

```obj-c
@interface Person : NSObject

@property (copy, nonatomic) NSNumber *ID;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;

@end

...

// Dictionary with some key/value pairs representing a person
NSDictionary *myDictionary = @{
    @"id" : @100,
    @"first_name" : @"Bob",
    @"last_name" : @"Smith"
};

// Create a new Person instance by automatically inferring key/property mappings
Person *newPerson = [Person rzi_objectFromDictionary:myDictionary];
NSLog(@"ID: %@ Name: %@ %@", newPerson.ID, newPerson.firstName, newPerson.lastName);
```

##### Console Output:

```
ID: 100 Name: Bob Smith
```
## Installation

#### CocoaPods (Preferred)

Add the following to your podfile and run `pod install`:

```
pod 'RZImport', '~> 1.0'
```

This project uses semantic versioning, so the version number can be changed to suit your project's needs as future versions are released. See the [CocoaPods guides](http://guides.cocoapods.org/using/the-podfile.html) for more details.

#### Manual Installation

Simply copy the files in the `Classes` directory into your project, add them to your target, and off you go!

**Note**: The `Private` directory contains private headers that are not intended for public usage.

## Documentation

##### For most in-depth and up-to-date documentation, please read the Apple-doc commented header files in the source code, or visit the [documentation page](http://cocoadocs.org/docsets/RZImport) on CocoaDocs.

### Basic Usage

RZImport can be used to create model objects from a either a dictionary or an array of dictionaries.

```obj-c
#import "NSObject+RZImport.h"

...

- (void)fetchThePeople
{
    [self.apiClient get:@"/people" completion:^(NSData *responseData, NSError *error) {

        if ( responseData ) {
            NSError *jsonErr = nil;
            id deserializedResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                                      options:kNilOptions
                                                                        error:&jsonErr];
            if ( deserializedResponse ) {
                // convert to native objects
                if ( [deserializedResponse isKindOfClass:[NSDictionary class]] ) {
                    Person *newPerson = [Person rzi_objectFromDictionary:deserializedResponse];
                    // ... do something with the person ...
                }
                else if ( [deserializedResponse isKindOfClass:[NSArray class]] ) {
                    NSArray *people = [Person rzi_objectsFromArray:deserializedResponse];
                    // ... do something with the people ...
                }
            }
            else {
                // Handle jsonErr
            }
        }
    }];
}

```

You can also update an existing object instance from a dictionary.

```obj-c
Person *myPerson = self.person;
[myPerson rzi_updateFromDictionary:someDictionary];
```

### Custom Mappings

If you need to provide a custom mapping from a dictionary key or keypath to a property name, implement the `RZImportable` protocol on your model class. Custom mappings will take precedence over inferred mappings, but both can be used for the same class.

```obj-c
#import "RZImportable.h"

@interface MyModelClass : NSObject <RZImportable>

@property (copy, nonatomic) NSNumber *objectID;
@property (copy, nonatomic) NSString *zipCode;

@end


@implementation MyModelClass

+ (NSDictionary *)rzi_customKeyMappings
{
    // Map dictionary key "zip" to property "zipCode"
    // and dictionary key "id" to property "objectID"
    return @{
        @"zip" : @"zipCode",
        @"id" : @"objectID"
    };
}

@end

```

You can also prevent RZImport from importing a value for a particular key, or import the value of a key using your own custom logic.

```obj-c
- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key;
{
    if ( [key isEqualToString:@"zip"] ) {
        // validation - must be a string that only contains numbers
        if ( [value isKindOfClass:[NSString class]] ) {
            return ([value rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound);
        }
        return NO;
    }
    else if ( [key isEqualToString:@"address"] ) {
        if ( [value isKindOfClass:[NSDictionary class]] ) {
            // custom import logic
            self.address = [Address rzi_objectFromDictionary:value];
        }
        return NO;
    }
    return YES;
}

```

### Nested Dictionaries

If you are importing a dictionary with sub-dictionaries that correspond to objects that you want to also be imported using RZImport, you can implement the `RZImportable` protocol and return the keys from `rzi_nestedObjectKeys`.

```obj-c
@interface Job : NSObject

@property (copy, nonatomic) NSString *jobTitle;
@property (copy, nonatomic) NSString *companyName;

@end

@interface Person : NSObject <RZImportable>

@property (strong, nonatomic) Job *job;
@property (copy, nonatomic) NSString *firstName;

@end

@implementation Person

+ (NSArray *)rzi_nestedObjectKeys
{
    return @[ @"job" ];
}

@end

...
- (void)createPersonWithJob
{
    NSDictionary *personData = @{
                    @"firstName" : @"John",
                    @"job" : @{
                        @"jobTitle" : @"Software Developer",
                        @"companyName" : @"Raizlabs"
                    }
                };
    Person *p = [Person rz_objectFromDictionary:personData];
}
```

### Uniquing Objects

`RZImportable` also has a handy method that you can implement on your classes to prevent duplicate objects from being created when using `rzi_objectFromDictionary:` or `rzi_objectsFromArray:`.

```obj-c
+ (id)rzi_existingObjectForDict:(NSDictionary *)dict
{
    // If there is already an object in the data store with the same ID, return it.
    // The existing instance will be updated and returned instead of a new instance.
    NSNumber *objID = [dict objectForKey:@"id"];
    if ( objID != nil ) {
        return [[DataStore sharedInstance] objectWithClassName:@"Person" forId:objID];
    }
    return nil;
}
```

## Known Issues

RZImport uses the default designated initializer `init` when it creates new object instances, therefore it cannot be used out-of-the-box with classes that require another designated initializer. However, to get around this, you can override `+rzi_existingObjectForDict:` on any class to *always* return a new object created with the proper initializer (or an existing object).

For example, RZImport cannot be used out-of-the-box to create valid instances of a subclass of `NSManagedObject`, since managed objects must be initialized with an entity description. However, there is no reason it will not work for updating existing instances of a subclass of `NSManagedObject` from a dictionary, or by overriding `+rzi_existingObjectForDict` to return a new object inserted into the correct managed object context.

**If you are interested in using RZImport with CoreData, check out [RZVinyl](https://github.com/Raizlabs/RZVinyl)**

## License

RZImport is licensed under the MIT license. See the `LICENSE` file for details.
