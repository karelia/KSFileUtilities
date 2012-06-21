
// Private methods of NSURL+KSURLUtilities category.


#import "KSURLNormalization.h"


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


