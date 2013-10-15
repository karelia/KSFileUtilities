//
//  KSURLUtilities.m
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

#import "KSURLUtilities.h"

#import "KSPathUtilities.h"


@implementation NSURL (KSPathUtilities)

#pragma mark Scheme

- (NSURL *)ks_URLWithScheme:(NSString *)newScheme;
{
    NSString *scheme = [self scheme];
    if (!scheme) return nil;

    // -resourceSpecifier is supposed to give me everything after the scheme's colon, but for file:///path URLs, it just returns /path. Work around by deducing when resource specifier truly starts. Also found CFURLCopyResourceSpecifier() returns NULL for such URLs, against its documentation
    NSString *string = [[NSString alloc] initWithFormat:
                        @"%@:%@",
                        newScheme,
                        [[self absoluteString] substringFromIndex:[scheme length] + 1]];    // should be safe since a colon was needed to know scheme
    
    NSURL *result = [[self class] URLWithString:string];
    [string release];
    return result;
}

#pragma mark Host

- (NSURL *)ks_hostURL;		// returns a URL like "http://launch.karelia.com/"
{
    // TODO: maintains anything after the path like fragments or queries. That's probably not ideal, so instead just take a substring up to the start of the path
	NSURL *result = [self ks_URLByReplacingComponent:kCFURLComponentPath withString:@"/"];
    return result;
}


- (NSArray *)ks_domains;
{
    NSArray *result = [[self host] componentsSeparatedByString:@"."];
    return result;
}

- (BOOL)ks_hasNetworkLocation
{
	NSString *resourceSpecifier = [self resourceSpecifier];
	
	BOOL result = (resourceSpecifier != nil &&
				   [resourceSpecifier length] > 2 &&
				   [[self ks_domains] count] >= 2);
	
	return result;
}

- (NSURL *)ks_URLWithHost:(NSString *)host;
{
    return [self ks_URLByReplacingComponent:kCFURLComponentHost withString:host];
}

#pragma mark Paths

/*	These two methods operate very similarly to -initWithString:relativeToURL:
 *	However, they assume the string is a path and ensure it has a trailing slash to match isDirectory.
 */

+ (NSURL *)ks_URLWithPath:(NSString *)path relativeToURL:(NSURL *)baseURL isDirectory:(BOOL)isDirectory
{
	NSParameterAssert(path);
    
	if ([path hasSuffix:@"/"] != isDirectory)
	{
		if (isDirectory)
		{
			path = [path stringByAppendingString:@"/"];
		}
		else
		{
			path = [path substringToIndex:(path.length - 1)];
		}
	}
    
    // Properly escape
    CFStringRef encodedPath = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                      (CFStringRef)path,
                                                                      NULL,
                                                                      CFSTR(";?#"),
                                                                      kCFStringEncodingUTF8);
	
    // Work around 10.6 bug by effectively "faulting in" the base URL
    if ([path isAbsolutePath] && [baseURL isFileURL]) [baseURL absoluteString];
    
	NSURL *result =  [self URLWithString:(NSString *)encodedPath relativeToURL:baseURL];
    NSAssert(result, @"path wasn't escaped properly somehow: %@", path);
    
    CFRelease(encodedPath);
    return result;
}


/*  Getting a file:// URL from a path and then turning it into a string is pretty common for us.
 *  This is a simple method to make it faster.
 */
+ (NSString *)ks_fileURLStringWithPath:(NSString *)path;
{
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:path];
    NSString *result = [URL absoluteString];
    [URL release];
    
    return result;
}


#if !(defined MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6
// already defined in Snow Leopard

/*	The CFURL APIs expose a bunch more path functionality than NSURL. You could of course use
 *	toll-free bridging, but it's more hassle and less readable. So these methods are here
 *	to simplify that.
 */

- (NSString *)ks_lastPathComponent
{
	NSString *result = NSMakeCollectable(CFURLCopyLastPathComponent((CFURLRef)[self absoluteURL]));
	return [result autorelease];
}

- (NSString *)ks_pathExtension
{
	NSString *result = NSMakeCollectable(CFURLCopyPathExtension((CFURLRef)[self absoluteURL]));
	return [result autorelease];
}

- (NSURL *)ks_URLByAppendingPathExtension:(NSString *)pathExtension
{
	NSURL *result = NSMakeCollectable(CFURLCreateCopyAppendingPathExtension(NULL,
                                                                            (CFURLRef)self,
                                                                            (CFStringRef)pathExtension));
	return [result autorelease];
}

- (NSURL *)ks_URLByDeletingLastPathComponent
{
    NSURL *result = self;
    if ([[self path] length])   // #74010
    {
        result = NSMakeCollectable(CFURLCreateCopyDeletingLastPathComponent(NULL, (CFURLRef)self));
        [result autorelease];
    }
    
    return result;
}

- (NSURL *)ks_URLByDeletingPathExtension
{
	NSURL *result = NSMakeCollectable(CFURLCreateCopyDeletingPathExtension(NULL, (CFURLRef)self));
	return [result autorelease];
}

#endif

- (BOOL)ks_hasDirectoryPath
{
    BOOL result = CFURLHasDirectoryPath((CFURLRef)self);
    return result;
}

- (NSURL *)ks_URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory
{
    NSParameterAssert(pathComponent);
    
	NSURL *result = NSMakeCollectable(CFURLCreateCopyAppendingPathComponent(NULL,
                                                                            (CFURLRef)self,
                                                                            (CFStringRef)pathComponent,
                                                                            isDirectory));
	return [result autorelease];
}

/*  e.g. http://example.com/foo/bar.html is a subpath of http://example.com/foo/
 *  The URLs should have the same scheme and host. After that, path comparison is used
 */
- (BOOL)ks_isSubpathOfURL:(NSURL *)aURL;
{
    BOOL result = NO;
    
    
    // File URLs are treated specially to handle 'localhost' versus '///' and symlinks
    if ([self isFileURL] && [aURL isFileURL])
    {
        // Resolve aliases for local paths
        NSString *myPath = [[self path] stringByResolvingSymlinksInPath];
        NSString *otherPath = [[aURL path] stringByResolvingSymlinksInPath];
        
        result = [myPath ks_isSubpathOfPath:otherPath];
    }
    else
    {
        NSString *scheme = [self scheme];
        NSString *otherScheme = [aURL scheme];
        if (scheme && otherScheme && [scheme compare:otherScheme options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSString *myHost = [self host];
            NSString *otherHost = [aURL host];
            if (myHost && otherHost && [myHost compare:otherHost options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                NSString *myPath = [[self standardizedURL] path];
                NSString *otherPath = [[aURL standardizedURL] path];
                
                if (myPath && otherPath)
                {
                    // Account for URLs like http://example.com that have no path at all
                    if (myPath.length == 0) myPath = @"/";
                    if (otherPath.length == 0) otherPath = @"/";
                    
                    result = [myPath ks_isSubpathOfPath:otherPath];
                }
            }
        }
    }
    
    return result;
}

#pragma mark RFC 1808

- (BOOL)ks_canBeDecomposed { return CFURLCanBeDecomposed((CFURLRef)self); }

#pragma mark Relative URLs

- (NSString *)ks_stringRelativeToURL:(NSURL *)URL
{
    
#define BAIL return [self absoluteString];
    
    // If the base URL is nil then no comparison is needed
	if (!URL) BAIL;
	
	
	// URLs not compliant with RFC 1808 cannot be interpreted
	if (![self ks_canBeDecomposed] || ![URL ks_canBeDecomposed]) BAIL;
	
	
	// If the scheme, host or port differs, there is no possible relative path. Schemes and domains are considered to be case-insensitive. http://en.wikipedia.org/wiki/URL_normalization
    NSString *myHost = [self host];
    if (!myHost)
    {
        // If self is an empty URL, there's no way to get to it. Falls through to here; return nil
        NSString *result = [self absoluteString];
        return ([result length] ? result : nil);
    }
    
    NSString *otherHost = [URL host];
    if (!otherHost) BAIL;
    
    if ([myHost caseInsensitiveCompare:otherHost] != NSOrderedSame) BAIL;
    
    NSString *myScheme = [self scheme];
    if (!myScheme) BAIL;
    
    NSString *otherScheme = [URL scheme];
    if (!otherScheme) BAIL;
    
    if ([myScheme caseInsensitiveCompare:otherScheme] != NSOrderedSame) BAIL;
    
    NSNumber *myPort = [self port];
    NSNumber *aPort = [URL port];
    if (aPort != myPort && ![myPort isEqual:aPort]) // -isEqualToNumber: throws when passed nil
    {
        BAIL;
    }
	
	
	// OK, to figure out, need my path...
    CFURLRef absoluteSelf = CFURLCopyAbsoluteURL((CFURLRef)self);
    CFStringRef myPath = CFURLCopyPath((CFURLRef)absoluteSelf);
    
    if (!CFStringGetLength(myPath))     // e.g. http://example.com
    {
        CFRelease(myPath); myPath = CFRetain(CFSTR("/"));
    }
    
    
    // ... and the other path
    CFURLRef absoluteURL = CFURLCopyAbsoluteURL((CFURLRef)URL);
    CFStringRef dirPath = CFURLCopyPath(absoluteURL);
    
    if (!CFStringGetLength(dirPath))     
    {
        // e.g. http://example.com
        CFRelease(dirPath); dirPath = CFRetain(CFSTR("/"));
    }
    else if (!CFURLHasDirectoryPath(absoluteURL))   // faster than -ks_hasDirectoryPath
    {
        NSString *shortenedPath = [(NSString *)dirPath stringByDeletingLastPathComponent];
        CFRelease(dirPath); dirPath = CFRetain(shortenedPath);
    }
    
    CFRelease(absoluteURL);
    
    
    // Let -ks_pathRelativeToDirectory: do the heavy lifting
    NSString *result = [(NSString *)myPath ks_pathRelativeToDirectory:(NSString *)dirPath];
    
    // But here's an odd edge case, http://example.com/foo relative to http://example.com/foo/ should be '../foo' which -ks_pathRelativeToDirectory returns '.' from; perfectly fine for posix, but not us!
    if ([result isEqualToString:@"."])
    {
        if ([[(NSString *)myPath stringByAppendingString:@"/"] isEqualToString:(NSString *)dirPath])
        {
            result = [@"../" stringByAppendingString:[(NSString *)myPath lastPathComponent]];
        }
    }
    
    
    // Need trailing slash?
    if (CFURLHasDirectoryPath(absoluteSelf) && ![result hasSuffix:@"/"])
    {
        result = [result stringByAppendingString:@"/"];
    }
    
    
    // Time for a little cleanup
    CFRelease(dirPath);
    CFRelease(myPath);
    CFRelease(absoluteSelf);
    
    
    // Re-build any non-path information
	NSString *parameters = [self parameterString];
	if (parameters)
	{
		result = [result stringByAppendingFormat:@";%@", parameters];
	}
	
	NSString *query = [self query];
	if (query)
	{
		result = [result stringByAppendingFormat:@"?%@", query];
	}
	
	NSString *fragment = [self fragment];
	if (fragment)
	{
		result = [result stringByAppendingFormat:@"#%@", fragment];
	}
	
	
	// Finish up
	return result;
}

/*	Builds on -ks_stringRelativeToURL: by wrapping it into an NSURL object.
 */
- (NSURL *)ks_URLRelativeToURL:(NSURL *)URL;
{
	NSURL *result = nil;
	
	NSString *relativeString = [self ks_stringRelativeToURL:URL];
	if (relativeString)
	{
        // The 10.6 file URL bug can't kick in here because -ks_stringRelativeToURL: will have done enough to "fault it in"
		result = [NSURL URLWithString:relativeString relativeToURL:URL];
	}
	
	return result;
}

#pragma mark Comparison

- (BOOL)ks_isEqualToURL:(NSURL *)otherURL;
{
    BOOL result = [self isEqual:otherURL];
    
   // For file: URLs the default check might have failed because they reference the host differently. If so, fall back to checking paths
    if (!result && [self isFileURL] && [otherURL isFileURL])
    {
        result = [[self path] isEqualToString:[otherURL path]];
    }
    
    return result;
}

- (BOOL)ks_isEqualExceptFragmentToURL:(NSURL *)anotherURL
{
	// cover case where both are nil
	return	( ([self baseURL] == [anotherURL baseURL]) || [[self baseURL] isEqual:[anotherURL baseURL]] )
	&& 
	( ([self scheme] == [anotherURL scheme]) || [[self scheme] isEqual:[anotherURL scheme]] )
	&& 
	( ([self host] == [anotherURL host]) || [[self host] isEqual:[anotherURL host]] )
	&& 
	( ([self path] == [anotherURL path]) || [[self path] isEqual:[anotherURL path]] )
	&& 
	
	// query == parameterString?
    
	( ([self query] == [anotherURL query]) || [[self query] isEqual:[anotherURL query]] )
	&& 
	( ([self parameterString] == [anotherURL parameterString]) || [[self parameterString] isEqual:[anotherURL parameterString]] )
	&& 
	( ([self baseURL] == [anotherURL baseURL]) || [[self baseURL] isEqual:[anotherURL baseURL]] )
	
	// less common pieces, but we gotta be careful
	&& 
	( ([self baseURL] == [anotherURL baseURL]) || [[self baseURL] isEqual:[anotherURL baseURL]] )
	&& 
	( ([self port] == [anotherURL port]) || [[self port] isEqual:[anotherURL port]] )
	&& 
	( ([self password] == [anotherURL password]) || [[self password] isEqual:[anotherURL password]] )
	&& 
	( ([self user] == [anotherURL user]) || [[self user] isEqual:[anotherURL user]] )
	;
	
}

#pragma mark Security-Scoped Bookmarks

- (void)ks_accessSecurityScopedResourceUsingBlock:(void (^)(BOOL started))block;
{
    BOOL started = NO;
    if ([self respondsToSelector:@selector(startAccessingSecurityScopedResource)])
    {
        started = [self startAccessingSecurityScopedResource];
    }
    
    @try
    {
        block(started);
    }
    @finally
    {
        if (started) [self stopAccessingSecurityScopedResource];
    }
}

#pragma mark Components

- (NSURL *)ks_URLByReplacingComponent:(CFURLComponentType)component withString:(NSString *)string;
{
    NSParameterAssert(string);
    
    NSURL *result = nil;
    CFURLRef absolute = CFURLCopyAbsoluteURL((CFURLRef)self);
    
    CFRange rangeIncludingSeparators;
    CFRange range = CFURLGetByteRangeForComponent(absolute, component, &rangeIncludingSeparators);
    
    // If there isn't an existing hostname, CFURL helpfully tells us where it would go
    if (range.location == kCFNotFound)
    {
        range = rangeIncludingSeparators;
    }
    
    if (range.location != kCFNotFound)
    {
        // Grab data
        CFIndex length = CFURLGetBytes(absolute, NULL, 0);
        NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
        length = CFURLGetBytes(absolute, [data mutableBytes], [data length]);
        NSAssert(length == [data length], @"CFURLGetBytes() lied to us!");
        
        // Replace the host
        NSData *hostData = [string dataUsingEncoding:NSASCIIStringEncoding];
        [data replaceBytesInRange:NSMakeRange(range.location, range.length) withBytes:[hostData bytes] length:[hostData length]];
        
        // Create final URL
        result = NSMakeCollectable(CFURLCreateWithBytes(NULL, [data bytes], [data length], kCFStringEncodingASCII, NULL));
        [result autorelease];
        [data release];
    }
    
    CFRelease(absolute);
    return result;
}

@end


#pragma mark -


@implementation NSString (KSURLUtilities)

- (NSString *)ks_stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding
                             charactersToLeaveUnescaped:(NSString *)unescapedCharacters
                          legalURLCharactersToBeEscaped:(NSString *)legalCharactersToEscape;
{
    NSString *result = NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 (CFStringRef)unescapedCharacters,
                                                                                 (CFStringRef)legalCharactersToEscape,
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
    
    return [result autorelease];
}

- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters
{
	// Add the percent escapes. If encodeSpacesAsPlusCharacters has been requested, then don't both escaping them
    NSString *charactersToLeaveUnescaped = (encodeSpacesAsPlusCharacters) ? @" " : @"";
    
    NSString *result = [self ks_stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
                                            charactersToLeaveUnescaped:charactersToLeaveUnescaped
                                         legalURLCharactersToBeEscaped:@"&+%="];
    
    
    // If the user requested it, replace spaces with + signs
    if (encodeSpacesAsPlusCharacters)
    {
        NSMutableString *mutableResult = [result mutableCopy];
        [mutableResult replaceOccurrencesOfString:@" "
                                       withString:@"+"
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [mutableResult length])];
        
        result = [mutableResult autorelease];
    }
    
    
    return result;
}

// For more fine grain escaping.... we want to escape dashes when URLs are in comments.
- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters escape:(NSString *)toEscape;
{
	// Add the percent escapes. If encodeSpacesAsPlusCharacters has been requested, then don't both escaping them
    NSString *charactersToLeaveUnescaped = (encodeSpacesAsPlusCharacters) ? @" " : @"";
    
    NSString *result = [self ks_stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
                                            charactersToLeaveUnescaped:charactersToLeaveUnescaped
                                         legalURLCharactersToBeEscaped:toEscape];
    
    
    // If the user requested it, replace sapces with + signs
    if (encodeSpacesAsPlusCharacters)
    {
        NSMutableString *mutableResult = [result mutableCopy];
        [mutableResult replaceOccurrencesOfString:@" "
                                       withString:@"+"
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [mutableResult length])];
        
        result = [mutableResult autorelease];
    }
    
    
    return result;
}

/*	Turns a given path into a directory path suitable for HTML.
 *
 *		e.g.	/photo_album	->	/photo_album/
 *	
 *	Empty strings are ignored
 */
- (NSString *)ks_URLDirectoryPath
{
	NSString *result = self;
	
	if (![self isEqualToString:@""] && ![self hasSuffix:@"/"])
	{
		result = [self stringByAppendingString:@"/"];
	}
	
	return result;
}

@end
