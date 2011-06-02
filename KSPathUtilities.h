//
//  KSPathUtilities.h
//
//  Copyright (c) 2005-2011, Dan Wood, Mike Abdullah and Karelia Software
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>


@interface NSString (KSPathUtilities)

#pragma mark Path Suffix

// Given a path "foo/bar.png", adjusts it to be "foo/bar-2.png". Calling -ks_stringByIncrementingPath on that string will then give "foo/bar-3.png" and so on
// More at http://www.mikeabdullah.net/incrementing-paths.html
- (NSString *)ks_stringByIncrementingPath;

// like -stringByAppendingString: but inserts the suffix string in front of path extension if there is one. e.g. [@"foo.png" ks_stringWithPathSuffix:@"-2"] = @"foo-2.png"
- (NSString *)ks_stringWithPathSuffix:(NSString *)aString;


#pragma mark Comparing Paths

// Standardizes the paths and tests equality ignoring case
- (BOOL)ks_isEqualToPath:(NSString *)aPath;

- (BOOL)ks_isSubpathOfPath:(NSString *)aPath;  // Does aPath contain self?

// Will preserve any trailing slashes that are part of self
- (NSString *)ks_pathRelativeToDirectory:(NSString *)otherPath;


#pragma mark POSIX Paths

// NSString has built-in methods for standardizing a path, but they consult the filesystem for symlinks. This method only looks at the path itself
- (NSString *)ks_standardizedPOSIXPath;

// Like -isEqualToString: but ignores trailing slashes
- (BOOL)ks_isEqualToPOSIXPath:(NSString *)otherPath;

@end
