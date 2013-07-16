//
//  KSPathUtilities.h
//
//  Created by Mike Abdullah based on earlier code by Dan Wood
//  Copyright © 2005 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Cocoa/Cocoa.h>


@interface NSString (KSPathUtilities)

#pragma mark Making Paths
+ (NSString *)ks_stringWithPath:(NSString *)path relativeToDirectory:(NSString *)directory;


#pragma mark Path Suffix

// Given a path "foo/bar.png", adjusts it to be "foo/bar-2.png". Calling -ks_stringByIncrementingPath on that string will then give "foo/bar-3.png" and so on
// More at http://www.mikeabdullah.net/incrementing-paths.html
- (NSString *)ks_stringByIncrementingPath;

// like -stringByAppendingString: but inserts the suffix string in front of path extension if there is one. e.g. [@"foo.png" ks_stringWithPathSuffix:@"-2"] = @"foo-2.png"
- (NSString *)ks_stringWithPathSuffix:(NSString *)aString;


#pragma mark Finding Path Components

- (void)ks_enumeratePathComponentsInRange:(NSRange)range
                                  options:(NSStringEnumerationOptions)opts  // only NSStringEnumerationSubstringNotRequired is supported for now
                               usingBlock:(void (^)(NSString *component, NSRange componentRange, NSRange enclosingRange, BOOL *stop))block;

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
