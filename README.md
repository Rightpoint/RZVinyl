RZVinyl
=======

[![Build Status](https://travis-ci.org/Raizlabs/RZVinyl.svg)](https://travis-ci.org/Raizlabs/RZVinyl)

Stack management, ActiveRecord utilities, and seamless importing for CoreData.

===

# Installation

### CocoaPods (Reccommended)

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

# Overview

To use RZVinyl, first add `#import "RZVinyl.h"` to any classes that will need to use it, or to your app's `.pch` file. RZVinyl can be broken down into three basic areas of functionality, as follows.

### RZCoreDataStack

`RZCoreDataStack` is a class for building and managing CoreData stacks, including the model, managed object context, and persistent store coordinator. It has convenience methods for performing concurrent background operations with a separate managed object context, as well as a set of class methods for making a default stack available via the singleton pattern.

### RZVinylRecord

`RZVinylRecord` is a category on `NSManagedObject` which provides a partial implementation of the Active Record pattern. Each method in `NSManagedObject+RZVinylRecord` has two signatures - one which accepts a managed object context parameter, and one which uses the main managed object context from the default `RZCoreDataStack`. 

```
// Delete all objects of receiver's type in default stack's main context
+ (void)rzv_deleteAll;

// Delete all objects of receiver's type in the provided context
+ (void)rzv_deleteAllInContext:(NSManagedObjectContext *)context;
```

The no-context versions may only be used from the main thread, or an exception will be thrown. Similarly, if no default stack has been set, attempting to call one of these methods without providing a context will also throw an exception.

#### Creating/Updating

#### Fetching

#### Deleting

#### Saving

The semantics of saving an object in CoreData are rather different from what might be expected when using the Active Record pattern, particularly when dealing with a more complex context hierarchy, as in `RZCoreDataStack`. In order to persist changes to the persistent store, it is necessary to save the entire context tree all the way to its root, which also saves any other changes in any of the contexts along the way. To avoid unintended, non-obvious consequences, no "save" methods are provided for managed object classes via `RZVinylRecord`, and saving must be handled via managed object contexts and/or the CoreData stack.

To persist changes to objects in the main context, simply call `save:` on the `RZCoreDataStack`. This will save both the main context as well as the disk write context. If you are using a background or temporary context, you must save that context first before calling `save:` on the stack. Saving either of these separate contexts will automatically merge changes into the main context.

### RZImport Extensions


# Documentation

For more comprehensive documentation, see the (TODO) generated from the AppleDoc header comments.

# License

RZVinyl is licensed under the MIT license. See LICENSE for details.