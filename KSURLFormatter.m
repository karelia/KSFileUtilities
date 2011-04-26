//
//  KSURLFormatter.m
//
//  Copyright (c) 2008-2011, Mike Abdullah and Karelia Software
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
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "KSURLFormatter.h"

#import "KSURLUtilities.h"


@implementation KSURLFormatter

#pragma mark Class Methods

+ (NSURL *)URLFromString:(NSString *)string;
{
    // Encode the URL string
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)string,
                                                                        (CFStringRef)@"%+#",
                                                                        NULL,
                                                                        encoding);
    
    
    // If we're still left with a valid string, turn it into a URL
    NSURL *result = nil;
    if (escapedString)
    {
        result = [NSURL URLWithString:(NSString *)escapedString];
        if ( result )
        {
            if ( ![[result scheme] isEqualToString:@"http"]
                && ![[result scheme] isEqualToString:@"https"]
                && ![[result scheme] isEqualToString:@"ftp"]
                && ![[result scheme] isEqualToString:@"mailto"] )
            {
                // likely interpreting a colon for specifying port as the scheme
                NSString *escapedAddingScheme = [NSString stringWithFormat:@"http://%@", (NSString *)escapedString];
                result = [NSURL URLWithString:escapedAddingScheme];
            }
        }
        CFRelease(escapedString);
    }
    
    return result;
}

+ (BOOL)isValidEmailAddress:(NSString *)address;
{
    // for now, just validate that syntactically it it at least _@_.__
	// though we are not checking actual other characters.
    // we can refine this over time
    NSRange whereAt = [address rangeOfString:@"@"];
    BOOL OK = (whereAt.location != NSNotFound && whereAt.location >= 1);	// make sure there is an @ and it's not the first character
	if (OK)
	{
		NSInteger len = [address length] - whereAt.location;
		NSRange whereDot = [address rangeOfString:@"." options:0 range:NSMakeRange(whereAt.location, len)];
		OK = (whereDot.location != NSNotFound);
		if (OK)
		{
			// make sure there is room between the @ and the .
			OK = (whereDot.location - whereAt.location >= 2) && ([address length] - whereDot.location >= 3);
		}
	}
	return OK;
}

#pragma mark Init & Dealloc

- (id)init
{
    [super init];
    _fallbackTopLevelDomain = [@"com" retain];
    return self;
}

- (void)dealloc
{
    [_fallbackTopLevelDomain release];
    [super dealloc];
}

#pragma mark Managing Behaviour

@synthesize useDisplayNameForFileURLs = _useDisplayNameForFileURLs;
@synthesize fallbackTopLevelDomain = _fallbackTopLevelDomain;

#pragma mark Textual Representation of Cell Content

- (NSString *)stringForObjectValue:(id)anObject
{
    NSString *result = @"";
    
    if (anObject)
    {
        if ([anObject isKindOfClass:[NSURL class]])
        {
            NSURL *URL = anObject;
            
            if ([self useDisplayNameForFileURLs] && [anObject isFileURL])
            {
                result = [[NSFileManager defaultManager] displayNameAtPath:[URL path]];
            }
            else
            {
                result = [URL absoluteString];
                
                // Append trailing slash if needed
                if ([URL ks_hasNetworkLocation] && [[URL path] isEqualToString:@""])
                {
                    result = [result stringByAppendingString:@"/"];
                }
            }
        }
        else
        {
            result = nil;   // when might this occur? – Mike
        }
    }
    
    return result;
}

#pragma mark Object Equivalent to Textual Representation

+ (NSURL *)URLFromString:(NSString *)string fallbackScheme:(NSString *)fallbackScheme;
{
	//  Tries to interpret the string as a complete URL. If there is no scheme specified, try it as an email address. If that doesn't seem reasonable, combine with fallbackScheme

    
    NSURL *result = [self URLFromString:string];
	
	// this is probably a really naive check
	if (![result scheme] && ![string hasPrefix:@"/"])
	{
        // if it looks like an email address, use mailto:
        if ([self isValidEmailAddress:string])
        {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", string]];
        }
        else
        {
            result = [self URLFromString:[NSString stringWithFormat:
                                                   @"%@://%@",
                                                   fallbackScheme,
                                                   string]];
        }
	}
    
    
    // Append a trailing slash if needed
    if ([result ks_hasNetworkLocation] && [[result path] isEqualToString:@""])
    {
        result = [[NSURL URLWithString:@"/" relativeToURL:result] absoluteURL];
    }
	
    return result;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
    BOOL result = YES;
    NSURL *URL = nil;
    
    if ([string length] > 0)
    {
        URL = [KSURLFormatter URLFromString:string fallbackScheme:@"http"];
        
        
        // Does the URL have no useful resource specified? If so, generate nil URL
        if (URL && ![[URL scheme] isEqualToString:@"mailto"])
        {
            NSString *resource = [URL resourceSpecifier];
            if ([resource length] == 0 ||
                [resource isEqualToString:@"/"] ||
                [resource isEqualToString:@"//"])
            {
                URL = nil;
            }
            
            
            
            // URLs should also really have a host and a path
            if (URL)
            {
                NSString *host = [URL host];
                NSString *path = [URL path];
                if (!host && !path)
                {
                    URL = nil;
                }
            }
        }
        
        
        // Did the user not enter a top-level domain? We'll guess for them
        if (URL && [self fallbackTopLevelDomain])
        {
            if ([[URL ks_domains] count] == 1)
            {
                NSString *urlString = [NSString stringWithFormat:
                                       @"%@://%@.%@/",
                                       [URL scheme],
                                       [URL host],
                                       [self fallbackTopLevelDomain]];
                URL = [NSURL URLWithString:urlString];
            }
        }
    }
    
    
    // Finish up
    if (result && anObject) *anObject = URL;
    return result;
}

- (NSURL *)URLFromString:(NSString *)string;
{
    NSURL *result = nil;
    
    NSURL *URL;
    if ([self getObjectValue:&URL forString:string errorDescription:NULL]) result = URL;
    
    return result;
}

@end
