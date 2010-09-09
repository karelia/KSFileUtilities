//
//  KSPathUtilities.h
//  Sandvox
//
//  Created by Mike on 09/09/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (KSPathUtilities)

// Will preserve any trailing slashes that are part of self
- (NSString *)ks_pathRelativeToDirectory:(NSString *)otherPath;

- (BOOL)ks_isSubpathOfPath:(NSString *)aPath;  // Does aPath contain self?

// NSString has built-in methods for standardizing a path, but they consult the filesystem for symlinks. This method only looks at the path itself
- (NSString *)ks_standardizedPOSIXPath;

// Like -isEqualToString: but ignores trailing slashes
- (BOOL)ks_isEqualToPOSIXPath:(NSString *)otherPath;

@end
