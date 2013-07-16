//
//  KSURLUtilities.h
//
//  Created by Mike Abdullah
//  Copyright © 2007 Karelia Software
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


@interface NSURL (KSPathUtilities)

#pragma mark Scheme
- (NSURL *)ks_URLWithScheme:(NSString *)scheme;


#pragma mark Host
- (NSURL *)ks_hostURL;
- (NSArray *)ks_domains;
- (BOOL)ks_hasNetworkLocation; // checks for a host with 2+ domains
- (NSURL *)ks_URLWithHost:(NSString *)host; // swaps out host for a new one


#pragma mark Paths

+ (NSURL *)ks_URLWithPath:(NSString *)path relativeToURL:(NSURL *)baseURL isDirectory:(BOOL)isDirectory;

+ (NSString *)ks_fileURLStringWithPath:(NSString *)path;

- (BOOL)ks_hasDirectoryPath;
- (NSURL *)ks_URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory;

- (BOOL)ks_isSubpathOfURL:(NSURL *)aURL;


#pragma mark Paths - Pre-Snowy compatibility

// If you're targeting 10.6+, these methods are provided by Foundation, so we just #define them for compatibility
#if !(defined MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6
- (NSString *)ks_lastPathComponent;
- (NSString *)ks_pathExtension;
- (NSURL *)ks_URLByAppendingPathExtension:(NSString *)pathExtension;
- (NSURL *)ks_URLByDeletingLastPathComponent;
- (NSURL *)ks_URLByDeletingPathExtension;
#else
#define ks_lastPathComponent lastPathComponent
#define ks_pathExtension pathExtension
#define ks_URLByAppendingPathExtension URLByAppendingPathExtension
#define ks_URLByDeletingLastPathComponent URLByDeletingLastPathComponent
#define ks_URLByDeletingPathExtension URLByDeletingPathExtension
#endif


#pragma mark RFC 1808
- (BOOL)ks_canBeDecomposed;


#pragma mark Comparison
- (BOOL)ks_isEqualToURL:(NSURL *)URL;   // For file: URLs, checks path equality
- (BOOL)ks_isEqualExceptFragmentToURL:(NSURL *)anotherURL;


#pragma mark Relative URLs
// These methods return nil if the receiver can't be reached by a relative string. In practice, to my knowledge that only happens for a URL from an empty string (@"")
- (NSString *)ks_stringRelativeToURL:(NSURL *)URL;
- (NSURL *)ks_URLRelativeToURL:(NSURL *)URL;


#pragma mark Security-Scoped Bookmarks
// Automatically:
// * stops access to the resource at the end of the block, even if an exception is thrown
// * runs the block pre-10.7.3. On those older OS releases, the value of 'started' is undefined
- (void)ks_accessSecurityScopedResourceUsingBlock:(void (^)(BOOL started))block;


#pragma mark Components
- (NSURL *)ks_URLByReplacingComponent:(CFURLComponentType)component withString:(NSString *)string;


@end


#pragma mark -


@interface NSString (KSURLUtilities)

// Cocoa equivalent of the full CoreFoundation API
- (NSString *)ks_stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding
                             charactersToLeaveUnescaped:(NSString *)unescapedCharacters
                          legalURLCharactersToBeEscaped:(NSString *)legalCharactersToEscape;

// For escaping anything where you want a / character left intact. But do NOT use on a full URL, because it will escape the & characters
- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters;
- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters escape:(NSString *)toEscape;

- (NSString *)ks_URLDirectoryPath;

@end
