/* RExplorer-OutlineDelegate.h created by epeyton on Tue 11-Jan-2000 */

#import <AppKit/AppKit.h>
#import "RExplorer.h"

@interface RExplorer (OutlineDelegate)

- (int) splitInplaceStringIntoMultipleLinesAtSpaces:(NSMutableString *)inString;

- (NSString *)CFDataShow:(CFDataRef)inObject;

- (NSString *)CFDataShowAsAutomaticAsciiOrUntypedData:(CFDataRef)object;

- (NSString *)CFDataShowAsScalars:(CFDataRef)inObject
						asDatumSizesInBytes:(int)inDatumSizesInBytes
						asBigEndians:(BOOL)inBigEndians
						asRadixes:(int)inRadixes
						asNSStringEncodings:(int)inNSStringEncodings
						showHeader:(BOOL)inHeader
						showBetweenSeparators:(NSString *)inBetweenSeparators
						showStartSeparator:(NSString *)inStartSeparator
						showEndSeparator:(NSString *)inEndSeparator;
						
- (NSString *)CFDatumShowAsScalar:(NSArray *)inDatum
						asBigEndian:(BOOL)inBigEndian
						asRadix:(int)inRadix
						asEncoding:(int)inNSStringEncoding
						asBitSize:(int)inBitSize;

@end
