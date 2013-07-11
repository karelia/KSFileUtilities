//
//  KSURLComponents.h
//  KSFileUtilities
//
//  Created by Mike on 06/07/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSURLComponents : NSObject <NSCopying>
{
  @private
    NSString    *_schemeComponent;
    NSString    *_userComponent;
    NSString    *_passwordComponent;
    NSString    *_hostComponent;
    NSNumber    *_portComponent;
    NSString    *_pathComponent;
    NSString    *_queryComponent;
    NSString    *_fragmentComponent;
}

// Initialize a KSURLComponents with the components of a URL. If resolvingAgainstBaseURL is YES and url is a relative URL, the components of [url absoluteURL] are used. If the url string from the NSURL is malformed, nil is returned.
- (id)initWithURL:(NSURL *)url resolvingAgainstBaseURL:(BOOL)resolve;

// Initializes and returns a newly created KSURLComponents with the components of a URL. If resolvingAgainstBaseURL is YES and url is a relative URL, the components of [url absoluteURL] are used. If the url string from the NSURL is malformed, nil is returned.
+ (id)componentsWithURL:(NSURL *)url resolvingAgainstBaseURL:(BOOL)resolve;

// Initialize a KSURLComponents with a URL string. If the URLString is malformed, nil is returned.
- (id)initWithString:(NSString *)URLString;

// Initializes and returns a newly created KSURLComponents with a URL string. If the URLString is malformed, nil is returned.
+ (id)componentsWithString:(NSString *)URLString;

// Returns a URL created from the KSURLComponents. If the KSURLComponents has an authority component (user, password, host or port) and a path component, then the path must either begin with "/" or be an empty string. If the KSURLComponents does not have an authority component (user, password, host or port) and has a path component, the path component must not start with "//". If those requirements are not met, nil is returned.
- (NSURL *)URL;

// Returns a URL created from the KSURLComponents relative to a base URL. If the KSURLComponents has an authority component (user, password, host or port) and a path component, then the path must either begin with "/" or be an empty string. If the KSURLComponents does not have an authority component (user, password, host or port) and has a path component, the path component must not start with "//". If those requirements are not met, nil is returned.
- (NSURL *)URLRelativeToURL:(NSURL *)baseURL;

// Warning: IETF STD 66 (rfc3986) says the use of the format "user:password" in the userinfo subcomponent of a URI is deprecated because passing authentication information in clear text has proven to be a security risk. However, there are cases where this practice is still needed, and so the user and password components and methods are provided.

// Getting these properties removes any percent encoding these components may have (if the component allows percent encoding). Setting these properties assumes the subcomponent or component string is not percent encoded and will add percent encoding (if the component allows percent encoding).
@property (copy) NSString *scheme; // Attempting to set the scheme with an invalid scheme string will cause an exception.
@property (copy) NSString *user;
@property (copy) NSString *password;
@property (copy) NSString *host;
@property (copy) NSNumber *port; // Attempting to set a negative port number will cause an exception.
@property (copy) NSString *path;
@property (copy) NSString *query;
@property (copy) NSString *fragment;

// Getting these properties retains any percent encoding these components may have. Setting these properties is currently not supported as I am lazy and doing so is rarely useful. If you do have a use case, please send me a pull request or file an issue on GitHub.
@property (copy, readonly) NSString *percentEncodedUser;
@property (copy, readonly) NSString *percentEncodedPassword;
@property (copy, readonly) NSString *percentEncodedHost;
@property (copy, readonly) NSString *percentEncodedPath;
@property (copy, readonly) NSString *percentEncodedQuery;
@property (copy, readonly) NSString *percentEncodedFragment;


@end
