
// Normalization of URLs based on 
//  http://en.wikipedia.org/wiki/URL_normalization


#import "NSURL+SVIURLUtils.h"


@implementation NSURL (SVIURLUtils)

- (NSURL *)sviURLByNormalizingURL
{
    NSURL *norm = self;
    norm = [norm sviURLByLowercasingSchemeAndHost];
    norm = [norm sviURLByUppercasingEscapes];
    norm = [norm sviURLByAddingTrailingSlashToDirectory];
    norm = [norm sviURLByRemovingDefaultPort];
    norm = [norm sviURLByRemovingDotSegments];
    norm = [norm sviURLByRemovingDirectoryIndex];
    norm = [norm sviURLByRemovingFragment];
    norm = [norm sviURLByRemovingDuplicateSlashes];
    return norm;
}


- (NSRange)sviReplacementRangeOfURLPart:(SVIURLPart)anURLPart
{
    // Determine correct range for replacing the specified URL part INCLUDING DELIMITERS.
    // Note that if the URL part is not found, the range length is 0, but the range location is NOT NSNotFound, but rather the location that the indicated URL part could be inserted.
    NSString *scheme = [[self scheme] lowercaseString];
    NSString *schemePart = @"://";
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
    if (anURLPart >= SVIURLPartScheme)
    {
        rPart.location += 0;
        rPart.length = [scheme length];
    }
    if (anURLPart >= SVIURLPartSchemePart)
    {
        rPart.location += [scheme length];
        rPart.length = [schemePart length];
    }
    if (anURLPart >= SVIURLPartUserAndPassword)
    {
        rPart.location += [schemePart length];
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
    if (anURLPart >= SVIURLPartHost)
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
    if (anURLPart >= SVIURLPartPort)
    {
        rPart.location += [host length];
        rPart.length = 0;
        if (port && [port length])
        {
            rPart.length = [port length] + [portDelimiter length];
        }
    }
    if (anURLPart >= SVIURLPartPath)
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
    if (anURLPart >= SVIURLPartParameterString)
    {
        rPart.location += [path length];
        rPart.length = 0;
        if (parameterString && [parameterString length])
        {
            rPart.length = [parameterString length] + [parameterDelimiter length];
        }
    }
    if (anURLPart >= SVIURLPartQuery)
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
    if (anURLPart >= SVIURLPartFragment)
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

- (NSURL *)sviURLByLowercasingSchemeAndHost
{
    NSRange rScheme = [self sviReplacementRangeOfURLPart:SVIURLPartScheme];
    NSRange rHost = [self sviReplacementRangeOfURLPart:SVIURLPartHost];
    NSString *schemeLower = [[self scheme] lowercaseString];
    NSString *hostLower = (rHost.length > 0) ? [[self host] lowercaseString] : @"";
    NSString *abs = [self absoluteString];
    abs = [abs stringByReplacingCharactersInRange:rScheme withString:schemeLower];
    abs = [abs stringByReplacingCharactersInRange:rHost withString:hostLower];
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
}


- (NSURL *)sviURLByUppercasingEscapes
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


- (NSURL *)sviURLByAddingTrailingSlashToDirectory
{
    NSString *pathExt = [self pathExtension];
    if (pathExt && [pathExt length] > 0)
    {   // No need for trailing slash.
        return self;
    }
    NSRange rPath = [self sviReplacementRangeOfURLPart:SVIURLPartPath];
    NSString *abs = [self absoluteString];
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


- (NSURL *)sviURLByRemovingDefaultPort
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
    
    NSRange rPort = [self sviReplacementRangeOfURLPart:SVIURLPartPort];
    NSString *abs = [self absoluteString];
    abs = [abs stringByReplacingCharactersInRange:rPort withString:@""];
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
}


- (NSURL *)sviURLByRemovingDotSegments
{
    return [self standardizedURL];
}


#pragma mark Normalizations that change semantics.

- (NSURL *)sviURLByRemovingDirectoryIndex
{
    // No doc specified in URL, early return.
    NSString *pathExt = [self pathExtension];
    if (!pathExt || [pathExt length] == 0)
    {   // No page specified at all. 
        return self;
    }
    
    // Check whether a "directory index" page specified in URL.
    NSString *lastPathComponent = [[self lastPathComponent] lowercaseString];
    BOOL removeDefaultPage = NO;
    NSArray *defaultsArray = [NSArray arrayWithObjects:
        @"index.html",
        @"index.htm",
        @"index.php",
        @"index.asp",
        @"index.aspx",
        @"index.cfm",
        @"default.htm",
        @"default.asp",
        @"default.aspx",
        nil
    ];
    for (NSString *defPage in defaultsArray)
    {
        if ([defPage isEqualToString:lastPathComponent])
        {
            removeDefaultPage = YES;
            break;
        }
    }
    if (!removeDefaultPage)
    {
        return self;
    }
    
    NSRange rPath = [self sviReplacementRangeOfURLPart:SVIURLPartPath];
    NSString *abs = [self absoluteString];
    lastPathComponent = [self lastPathComponent];   // preserve case
    NSString *correctedStr = [abs stringByReplacingOccurrencesOfString:lastPathComponent withString:@"" options:NSBackwardsSearch range:rPath];
    NSURL *correctedURL = [NSURL URLWithString:correctedStr];
    return correctedURL;
}


- (NSURL *)sviURLByRemovingFragment
{
    NSRange rFragment = [self sviReplacementRangeOfURLPart:SVIURLPartFragment];
    if (rFragment.length == 0)
    {
        return self;
    }
    
    NSString *abs = [self absoluteString];
    abs = [abs stringByReplacingCharactersInRange:rFragment withString:@""];
    NSURL *correctedURL = [NSURL URLWithString:abs];
    return correctedURL;
}


- (NSURL *)sviURLByRemovingDuplicateSlashes
{
    NSRange rPath = [self sviReplacementRangeOfURLPart:SVIURLPartPath];
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


//- (NSURL *)sviURLByRemovingEmptyQuery
//{
//    NSRange rQuery = [self sviReplacementRangeOfURLPart:SVIURLPartQuery];
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
