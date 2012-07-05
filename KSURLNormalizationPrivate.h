
// Private methods of NSURL+KSURLUtilities category.


#import "KSURLNormalization.h"


typedef enum  
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
} ks_URLPart;


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


