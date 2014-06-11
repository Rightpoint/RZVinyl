RZVinyl
=======

[![Build Status](https://travis-ci.org/Raizlabs/RZVinyl.svg)](https://travis-ci.org/Raizlabs/RZVinyl)

ActiveRecord extensions for CoreData.

===

# Installation

### CocoaPods (Reccommended)

Add the following to your Podfile:

```
pod RZVinyl, '~> 1.0'
```

To exclude RZAutoImport extensions, use the `Core` subspec: 

```
pod RZVinyl/Core, '~> 1.0'
```

RZVinyl follows semantic versioning conventions. As newer versions are released, you will need to update the version spec in your Podfile as necessary.

### Manual Installation

##### Without Import Extensions

Simply copy/add the contents of `Classes/` into your project, excluding the `Extensions/` directory, and ensure that you are linking with CoreData.

##### With Import Extensions

Because of the optional RZAutoImport extensions, which depend on the RZAutoImport library, manual installation is a bit more difficult. Hence why CocoaPods is the recommended installation method.

To install manually with RZAutoImport extensions:

1. Follow the steps for installing without import extensions.
2. Install [RZAutoImport](https://github.com/Raizlabs/RZAutoImport) in your project as well.
3. Add the following to your build configuration's compiler flags:
```
-DRZV_AUTOIMPORT_AVAILABLE=1
```

If all went well, your project should build cleanly and  the methods from `NSManagedObject+RZAutoImport.h` should be available for usage.

# Overview

To use RZVinyl, first add `#import "RZVinyl.h"` to any classes that will need to use it, or to your app's `.pch` file.

# Documentation

For more detailed documentation, see the (TODO) generated from the AppleDoc header comments.

# License

RZVinyl is licensed under the MIT license. See LICENSE for details.