
// Normalization of URLs based on 
//  http://en.wikipedia.org/wiki/URL_normalization

/*  Example of an URL containing all valid parts.
    http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    The "parameter" is very rarely used and not well supported.
 
    NSURL methods return the following:
    absoluteString: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1

    absoluteURL: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    baseURL: (null)
 
    fragment: anchor1
 
    host: www.karelia.com
 
    lastPathComponent: index.html
 
    parameterString: parameter1=arg1;parameter2=arg2
 
    password: password
 
    path: /sandvox/index.html
 
    pathComponents: ("/", sandvox, "index.html" )
 
    pathExtension: html
 
    port: 8888
 
    query: queryparm1=queryarg1&queryparm2=queryarg2
 
    relativePath: /sandvox/index.html
 
    relativeString: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    resourceSpecifier: //username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    scheme: http
 
    standardizedURL: http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1
 
    user: username

*/

#import <Foundation/Foundation.h>



typedef enum  
{
    SVIURLPartScheme = 10,
    SVIURLPartSchemePart = 20,
    SVIURLPartUserAndPassword = 30,
    //SVIURLPartPassword = 40,
    SVIURLPartHost = 50,
    SVIURLPartPort = 60,
    SVIURLPartPath = 70,
    SVIURLPartParameterString = 80,
    SVIURLPartQuery = 90,
    SVIURLPartFragment = 100
} SVIURLPart;



@interface NSURL (SVIURLUtils)

#pragma mark 


#pragma mark 

// Overall normalization method.
- (NSURL *)sviURLByNormalizingURL;


- (NSRange)sviReplacementRangeOfURLPart:(SVIURLPart)anURLPart;


#pragma mark Normalizations that preserve semantics.
// Convert scheme and host to lower case.
- (NSURL *)sviURLByLowercasingSchemeAndHost;

// Capitalize letters in escape sequences.
- (NSURL *)sviURLByUppercasingEscapes;

// Decode percent-encoded octets of unreserved characters.
//- (NSURL *)sviURLByUnescapingUnreservedCharacters;

// Add trailing /.
- (NSURL *)sviURLByAddingTrailingSlashToDirectory;

// Remove default port.
- (NSURL *)sviURLByRemovingDefaultPort;

// Remove dot-segments.
- (NSURL *)sviURLByRemovingDotSegments;




#pragma mark Normalizations that change semantics.
// Remove directory index.
- (NSURL *)sviURLByRemovingDirectoryIndex;

// Remove the fragment.
- (NSURL *)sviURLByRemovingFragment;

// Replace IP with host.
//- (NSURL *)sviURLByReplacingIPWithHost;

// Remove duplicate slashes.
- (NSURL *)sviURLByRemovingDuplicateSlashes;

// Remove empty query string.
//- (NSURL *)sviURLByRemovingEmptyQuery;



@end


