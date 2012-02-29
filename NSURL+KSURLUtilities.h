
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
    ks_URLPartScheme = 10,
    ks_URLPartSchemePart = 20,
    ks_URLPartUserAndPassword = 30,
    //ks_URLPartPassword = 40,
    ks_URLPartHost = 50,
    ks_URLPartPort = 60,
    ks_URLPartPath = 70,
    ks_URLPartParameterString = 80,
    ks_URLPartQuery = 90,
    ks_URLPartFragment = 100
} ks_URLPart;


@interface NSURL (KSURLUtilities)

- (NSURL *)ks_normalizedURL;

@end


