//  Created by Warren Dodge
//  Copyright © 2012 Karelia Software
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
// Normalization of URLs based on 
//  http://en.wikipedia.org/wiki/URL_normalization


#import "KSURLNormalization.h"


#ifndef NS_ENUM
#define NS_ENUM(_type, _name) _type _name; enum
#endif

typedef NS_ENUM(NSInteger, ks_URLPart)
{
    ks_URLPartScheme = kCFURLComponentScheme,
    ks_URLPartPath = kCFURLComponentPath,
    ks_URLPartUserAndPassword = kCFURLComponentPassword - 1,
    //ks_URLPartPassword = kCFURLComponentPassword,
    ks_URLPartHost = kCFURLComponentHost,
    ks_URLPartPort = kCFURLComponentPort,
    ks_URLPartParameterString = kCFURLComponentParameterString,
    ks_URLPartQuery = kCFURLComponentQuery,
    ks_URLPartFragment = kCFURLComponentFragment
};


@interface NSURL (KSURLNormalizationPrivate)

- (NSRange)ks_replacementRangeOfURLPart:(ks_URLPart)anURLPart;

#pragma mark Normalizations that preserve semantics.
- (NSURL *)ks_URLByLowercasingSchemeAndHost;
- (NSURL *)ks_URLByUppercasingEscapes;
- (NSURL *)ks_URLByUnescapingUnreservedCharactersInPath;
- (NSURL *)ks_URLByAddingTrailingSlashToDirectory;
- (NSURL *)ks_URLByRemovingDefaultPort;
- (NSURL *)ks_URLByRemovingDotSegments;

#pragma mark Normalizations that change semantics.
- (NSURL *)ks_URLByRemovingDirectoryIndex;
- (NSURL *)ks_URLByRemovingFragment;
//- (NSURL *)ks_URLByReplacingIPWithHost;
- (NSURL *)ks_URLByRemovingDuplicateSlashes;
//- (NSURL *)ks_URLByRemovingEmptyQuery

@end


@implementation NSURL (KSURLNormalization)


- (NSURL *)ks_normalizedURL
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *norm = self;
    norm = [norm ks_URLByRemovingDuplicateSlashes]; // must be 1st!
    norm = [norm ks_URLByRemovingDotSegments];
    norm = [norm ks_URLByRemovingDuplicateSlashes];
    norm = [norm ks_URLByLowercasingSchemeAndHost];
    norm = [norm ks_URLByUppercasingEscapes];
    norm = [norm ks_URLByUnescapingUnreservedCharactersInPath];
	norm = [norm ks_URLByAddingTrailingSlashToDirectory];
    norm = [norm ks_URLByRemovingDefaultPort];
	if (![norm isFileURL])
	{
		norm = [norm ks_URLByRemovingDirectoryIndex];
	}
	norm = [norm ks_URLByRemovingFragment];
    [norm retain];
    
    [pool drain];
    
    return [norm autorelease];
}


- (NSRange)ks_replacementRangeOfURLPart:(ks_URLPart)anURLPart
{
    // Determine correct range for replacing the specified URL part INCLUDING DELIMITERS.
    // Note that if the URL part is not found, the range length is 0, but the range location is NOT NSNotFound, but rather the location that the indicated URL part could be inserted.
    // NOTE: Duplicate "/" must be removed from URL before finding the path's (and later URL element's) range is guaranteed correct!
    NSString *scheme = [[self scheme] lowercaseString];
    NSString *templateSchemePart = @"://";
    NSString *realSchemePart = @"";
    NSString *user = [self user];
    NSString *password = [self password];
    NSString *passwordDelimiter = @":";
    NSString *userDelimiter = @"@";
    NSString *host = [[self host] lowercaseString];
    NSString *port = nil;
    if ([[self port] intValue] > 0)
    {   // lurking bug: if port has leading 0
        port = [NSString stringWithFormat:@"%d", [[self port] intValue]];
    }
    NSString *portDelimiter = @":";
    NSString *path = [self path];   // updated later
    NSString *parameterString = [self parameterString];
    NSString *parameterDelimiter = @";";
    NSString *query = [self query];
    NSString *queryDelimiter = @"?";
    NSString *fragment = [self fragment];
    NSString *fragmentDelimiter = @"#";
    
    NSRange rPart = (NSRange){0,0};
    if (anURLPart >= ks_URLPartScheme)
    {
        rPart.location += 0;
        rPart.length = [scheme length];
    }
    if (anURLPart > ks_URLPartScheme)
    {
        rPart.location += [scheme length];
        
        NSRange testForSchemePart = NSMakeRange(rPart.location, [templateSchemePart length]);
        NSRange searchForSchemePart = [[self absoluteString] rangeOfString:templateSchemePart];
        if (NSEqualRanges(testForSchemePart, searchForSchemePart))
        {
            realSchemePart = templateSchemePart;
            rPart.length = [realSchemePart length];
        }
        else 
        {
            realSchemePart = @"";
            rPart.length = [realSchemePart length];
        }
    }
    if (anURLPart >= ks_URLPartUserAndPassword || anURLPart == ks_URLPartPath)
    {
        rPart.location += [realSchemePart length];
        rPart.length = 0;
        if (user && [user length])
        {
            rPart.length += ([user length] + [userDelimiter length]);
        }
        if (password && [password length])
        {
            rPart.length += ([password length] + [passwordDelimiter length]);
        }
    }
    if (anURLPart >= ks_URLPartHost || anURLPart == ks_URLPartPath)
    {
        if (user && [user length])
        {
            rPart.location += ([user length] + [userDelimiter length]);
        }
        if (password && [password length])
        {
            rPart.location += ([password length] + [passwordDelimiter length]);
        }
        rPart.length = [host length];
    }
    if (anURLPart >= ks_URLPartPort || anURLPart == ks_URLPartPath)
    {
        rPart.location += [host length];
        rPart.length = 0;
        if (port && [port length])
        {
            rPart.length = [port length] + [portDelimiter length];
        }
    }
    if (anURLPart >= ks_URLPartParameterString || anURLPart == ks_URLPartPath)
    {
        if (port && [port length])
        {
            rPart.location += ([port length] + [portDelimiter length]);
        }
        
        // NOTE: Duplicate "/" must be removed from URL before finding the path's (and later URL element's) range is guaranteed correct!
        
        // There are 2 problems with NSURL's path method: first it drops trailing "/" characters, second it percent-unescapes the path.
        // We have to work around those issues here.
        // Get the length of un-escaped path by comparing the length of complete URL to URL with path stripped.
        NSInteger urlLength = [[self absoluteString] length];
        NSURL *rootPathURL = [[self copy] autorelease];
        NSArray *pathComponents = [rootPathURL pathComponents];
        NSInteger cnt = [pathComponents count];
        for (NSInteger i = cnt; i > 1; i--)
        {
            rootPathURL = [rootPathURL URLByDeletingLastPathComponent];
        }
        // At this point, the path of rootPathURL is "/" or "".
        NSInteger rootPathURLLength = [[rootPathURL absoluteString] length];
        rPart.length = urlLength - rootPathURLLength + [[rootPathURL path] length];
        // Replace path with corrected version.
        path = [[self absoluteString] substringWithRange:rPart];
    }
    if (anURLPart >= ks_URLPartParameterString)
    {
        rPart.location += [path length];
        rPart.length = 0;
        if (parameterString && [parameterString length])
        {
            rPart.length = [parameterString length] + [parameterDelimiter length];
        }
    }
    if (anURLPart >= ks_URLPartQuery)
    {
        if (parameterString && [parameterString length])
        {
            rPart.location += ([parameterString length] + [parameterDelimiter length]);
        }
        rPart.length = 0;
        if (query && [query length])
        {
            rPart.length = [query length] + [queryDelimiter length];
        }
    }
    if (anURLPart >= ks_URLPartFragment)
    {
        if (query && [query length])
        {
            rPart.location += ([query length] + [queryDelimiter length]);
        }
        rPart.length = 0;
        if (fragment && [fragment length])
        {
            rPart.length = [fragment length] + [fragmentDelimiter length];
        }
        else
        {
            NSString *abs = [self absoluteString];
            if (rPart.location < [abs length])
            {
                NSString *maybeFragmentDelimiter = [abs substringWithRange:NSMakeRange(rPart.location, 1)];
                if ([maybeFragmentDelimiter isEqualToString:fragmentDelimiter])
                {
                    rPart.length = 1;
                }
            }
        }
    }

    return rPart;
}


#pragma mark Normalizations that preserve semantics.

// Convert scheme and host to lower case.
- (NSURL *)ks_URLByLowercasingSchemeAndHost
{
    // If both scheme and host are already lowercase, nothing need be done
    NSString *scheme = [self scheme];
    NSString *host = [self host];
    
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    
    if ([scheme rangeOfCharacterFromSet:uppercase].location == NSNotFound &&
        [host rangeOfCharacterFromSet:uppercase].location == NSNotFound)
    {
        return self;
    }
    
    
    NSRange rScheme = [self ks_replacementRangeOfURLPart:ks_URLPartScheme];
    NSRange rHost = [self ks_replacementRangeOfURLPart:ks_URLPartHost];
    NSString *abs = [self absoluteString];
    if ([scheme length])
    {
        abs = [abs stringByReplacingCharactersInRange:rScheme withString:[scheme lowercaseString]];
    }
    if ([host length])
    {
        abs = [abs stringByReplacingCharactersInRange:rHost withString:[host lowercaseString]];
    }
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
}


// Capitalize letters in escape sequences.
- (NSURL *)ks_URLByUppercasingEscapes
{
    // http://en.wikipedia.org/wiki/Percent_encoding
    
    NSString *anURLStr = [self absoluteString];
    NSRange rSearch = NSMakeRange(0, [anURLStr length]);
    while (rSearch.length > 0) 
    {
        NSRange rFound = [anURLStr rangeOfString:@"%" options:0 range:rSearch];
        if (rFound.location != NSNotFound)
        {
            rFound.length += 2;
            if (rFound.location + rFound.length < [anURLStr length])
            {
                NSString *escapeUpper = [[anURLStr substringWithRange:rFound] uppercaseString];
                anURLStr = [anURLStr stringByReplacingCharactersInRange:rFound withString:escapeUpper];
            }
            rSearch.location = rFound.location + rFound.length;
            rSearch.length = [anURLStr length] - rSearch.location;
        }
        else
        {
            // done
            break;
        }
    }
    NSURL *correctedURL = [NSURL URLWithString:anURLStr];
    return correctedURL;
}


// Decode percent-encoded octets of unreserved characters.
- (NSURL *)ks_URLByUnescapingUnreservedCharactersInPath
{
    NSString *abs = [self absoluteString];
    NSRange pathRange = [self ks_replacementRangeOfURLPart:ks_URLPartPath];
    NSString *rawPath = [abs substringWithRange:pathRange];
    
    // Transform only very limited characters: "!"
    // All reserved characters per RFC 3986: @" !*'();:@&=+$,/?#[]"
    // Since only 1 character, do this manually to avoid possible issues with unicode chars being unencoded.
    NSString *unescapedPath = [rawPath stringByReplacingOccurrencesOfString:@"%21" withString:@"!"];
    
    if ([unescapedPath isEqualToString:rawPath]) return self;
    
    NSString *unescapedURLString = [abs stringByReplacingCharactersInRange:pathRange withString:unescapedPath];
    NSURL *unescapedURL = [NSURL URLWithString:unescapedURLString];
    return unescapedURL;
}


// Add trailing "/".
- (NSURL *)ks_URLByAddingTrailingSlashToDirectory
{
    NSString *pathExt = [self pathExtension];
    if (pathExt && [pathExt length] > 0)
    {   // No need for trailing slash.
        return self;
    }
    NSRange rPath = [self ks_replacementRangeOfURLPart:ks_URLPartPath];
    if (rPath.length == 0 && [[self host] length] == 0)
    {   // No need for trailing slash.
        return self;
    }
    NSString *abs = [self absoluteString];
    if ([abs length] == 0)
    {
        return self;
    }
    NSString *path = [abs substringWithRange:rPath];
    if ([path rangeOfString:@"/" options:NSBackwardsSearch].location == ([path length] - 1))
    {   // last char of path is "/" already
        return self;
    }
    path = [path stringByAppendingString:@"/"];
    abs = [abs stringByReplacingCharactersInRange:rPath withString:path];
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
}


// Remove default port for http, https.
- (NSURL *)ks_URLByRemovingDefaultPort
{
    NSString *scheme = [[self scheme] lowercaseString];
    NSInteger portVal = [[self port] integerValue];
    BOOL removePort = NO;
    if ([scheme isEqualToString:@"http"] && portVal == 80)
    {
        removePort = YES;
    }
    else if ([scheme isEqualToString:@"https"] && portVal == 443)
    {
        removePort = YES;
    }
    if (!removePort)
    {
        return self;
    }
    
    NSRange rPort = [self ks_replacementRangeOfURLPart:ks_URLPartPort];
    NSString *abs = [self absoluteString];
    abs = [abs stringByReplacingCharactersInRange:rPort withString:@""];
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
}


// Remove dot-segments.
- (NSURL *)ks_URLByRemovingDotSegments
{
    NSURL *standardized = [self standardizedURL];
    if (standardized)
    {
        return standardized;
    }
    else 
    {
        return self;
    }
}


#pragma mark Normalizations that change semantics.

// Remove common directory index filenames.
- (NSURL *)ks_URLByRemovingDirectoryIndex
{
    // Check whether a "directory index" page specified in URL.
    NSString *lastPathComponent = [self lastPathComponent];
    
    static NSArray *defaultsArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultsArray = [[NSArray alloc] initWithObjects:
                         @"index.html",
                         @"index.htm",
                         @"index.php",
                         @"index.asp",
                         @"index.aspx",
                         @"index.cfm",
                         @"default.htm",
                         @"default.asp",
                         @"default.aspx",
                         nil];
    });
    
    for (NSString *defPage in defaultsArray)
    {
        if ([defPage caseInsensitiveCompare:lastPathComponent] == NSOrderedSame)
        {
            return [self URLByDeletingLastPathComponent];
        }
    }
    
    return self;
}


// Remove the fragment.
- (NSURL *)ks_URLByRemovingFragment
{
    NSRange rFragment = [self ks_replacementRangeOfURLPart:ks_URLPartFragment];
    if (rFragment.length == 0)
    {
        return self;
    }
    
    NSString *abs = [self absoluteString];
    abs = [abs stringByReplacingCharactersInRange:rFragment withString:@""];
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
}


// Replace IP with host.
//- (NSURL *)ks_URLByReplacingIPWithHost;


// Remove duplicate slashes.
- (NSURL *)ks_URLByRemovingDuplicateSlashes
{
    // Replace all duplicate slashes ("//") except if preceeded by ":"
    
    // NOTE: This method does not depend on the -ks_replacementRangeOfURLPart: method. This is required because all the URL ranges for the path and later URL components depend on this method being called on the URL first.
    NSMutableString *abs = [[[self absoluteString] mutableCopy] autorelease];
    NSRange schemeSlashesRange = [abs rangeOfString:@"://"];
    NSRange replaceRange;
    if (NSNotFound == schemeSlashesRange.location)
    {
        replaceRange = NSMakeRange(0, [abs length]);
    }
    else 
    {
        NSInteger start = schemeSlashesRange.location + schemeSlashesRange.length;
        replaceRange = NSMakeRange(start, [abs length] - start);
    }
    while ([abs replaceOccurrencesOfString:@"//" withString:@"/" options:0 range:replaceRange])
    {
        NSInteger start = schemeSlashesRange.location + schemeSlashesRange.length;
        replaceRange = NSMakeRange(start, [abs length] - start);
    }
    
    NSURL *cleanedURL = [NSURL URLWithString:abs];
    return cleanedURL;
        
//    // CFURLCopyStrictPath leaves out the first slash, so the resulting path is likely relative, making it safe to call -stringByStandardizingPath on
//    CFStringRef path = CFURLCopyStrictPath((CFURLRef)self, NULL);
//    if (!path) return self;
//    
//    // Deal with any leading slash such as from http://example.com//foo/
//    NSString *standardized = (NSString *)path;
//    while ([standardized isAbsolutePath]) standardized = [standardized substringFromIndex:1];
//    
//    standardized = [standardized stringByStandardizingPath];
//    
//    // Pop back on the directory indicator
//    if (CFURLHasDirectoryPath((CFURLRef)self)) standardized = [standardized stringByAppendingString:@"/"];
//    
//    BOOL changed = ![standardized isEqualToString:(NSString *)path];
//    CFRelease(path);
//    
//    if (!changed) return self;
//    
//    // Prepend the "/" that CFURLCopyStrictPath removed.
//    standardized = [NSString stringWithFormat:@"/%@", standardized];
//    
//    NSString *abs = [self absoluteString];
//    // The following line is our problem: ks_replacementRangeOfURLPart: for URL parts >= path are not valid until duplicate "/" characters have been removed.
//    NSRange rPath = [self ks_replacementRangeOfURLPart:ks_URLPartPath];
//    
//    abs = [abs stringByReplacingCharactersInRange:rPath withString:standardized];
//    NSURL *correctedURL = [NSURL URLWithString:abs];
//    return correctedURL;
}


// Remove empty query string.
//- (NSURL *)ks_URLByRemovingEmptyQuery
//{
//    NSRange rQuery = [self ks_replacementRangeOfURLPart:ks_URLPartQuery];
//    if (rQuery.length != 1)
//    {   // Not an empty query.
//        return self;
//    }
//    
//    NSString *abs = [self absoluteString];
//    abs = [abs stringByReplacingCharactersInRange:rQuery withString:@""];
//    NSURL *correctedURL = [NSURL URLWithString:abs];
//    return correctedURL;
//}


@end
