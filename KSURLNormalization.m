
// Normalization of URLs based on 
//  http://en.wikipedia.org/wiki/URL_normalization


#import "KSURLNormalization.h"
#import "KSURLNormalizationPrivate.h"


@implementation NSURL (KSURLNormalization)


- (NSURL *)ks_normalizedURL
{
    NSURL *norm = self;
    norm = [norm ks_URLByLowercasingSchemeAndHost];
    norm = [norm ks_URLByUppercasingEscapes];
    norm = [norm ks_URLByAddingTrailingSlashToDirectory];
    norm = [norm ks_URLByRemovingDefaultPort];
    norm = [norm ks_URLByRemovingDotSegments];
    norm = [norm ks_URLByRemovingDirectoryIndex];
    norm = [norm ks_URLByRemovingFragment];
    norm = [norm ks_URLByRemovingDuplicateSlashes];
    return norm;
}


- (NSRange)ks_replacementRangeOfURLPart:(ks_URLPart)anURLPart
{
    // Determine correct range for replacing the specified URL part INCLUDING DELIMITERS.
    // Note that if the URL part is not found, the range length is 0, but the range location is NOT NSNotFound, but rather the location that the indicated URL part could be inserted.
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
    NSString *path = [self path];
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
    if (anURLPart >= ks_URLPartSchemePart)
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
    if (anURLPart >= ks_URLPartUserAndPassword)
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
    if (anURLPart >= ks_URLPartHost)
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
    if (anURLPart >= ks_URLPartPort)
    {
        rPart.location += [host length];
        rPart.length = 0;
        if (port && [port length])
        {
            rPart.length = [port length] + [portDelimiter length];
        }
    }
    if (anURLPart >= ks_URLPartPath)
    {
        if (port && [port length])
        {
            rPart.location += ([port length] + [portDelimiter length]);
        }
        // If the URL has a trailing "/" in the path, NSURL's path method drops it. So check the next character in the URL if there is one.
        NSString *abs = [self absoluteString];
        NSRange rMayBeSlash = NSMakeRange(rPart.location + [path length], 1);
        if (rMayBeSlash.location < [abs length])
        {
            NSString *testSlash = [abs substringWithRange:rMayBeSlash];
            if ([testSlash isEqualToString:@"/"])
            {
                path = [path stringByAppendingString:@"/"];
            }
        }
        rPart.length = [path length];
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
        [scheme rangeOfCharacterFromSet:uppercase].location == NSNotFound)
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
//- (NSURL *)ks_URLByUnescapingUnreservedCharacters;


// Add trailing "/".
- (NSURL *)ks_URLByAddingTrailingSlashToDirectory
{
    NSString *pathExt = [self pathExtension];
    if (pathExt && [pathExt length] > 0)
    {   // No need for trailing slash.
        return self;
    }
    NSRange rPath = [self ks_replacementRangeOfURLPart:ks_URLPartPath];
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
    NSRange rPath = [self ks_replacementRangeOfURLPart:ks_URLPartPath];
    NSString *abs = [self absoluteString];
    NSString *goodPath = [abs substringWithRange:rPath];
    while ([goodPath rangeOfString:@"//"].location != NSNotFound) 
    {
        goodPath = [goodPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    abs = [abs stringByReplacingCharactersInRange:rPath withString:goodPath];
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
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
