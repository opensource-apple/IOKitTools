/* RExplorer-OutlineDelegate.m created by epeyton on Tue 11-Jan-2000 */

#import "RExplorer-OutlineDelegate.h"

@implementation RExplorer (OutlineDelegate)

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    [inspectorText setString:[item description]];
    [inspectorText display];
    return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    if (item == nil) {
        // root
        return [[currentSelectedItemDict allValues] objectAtIndex:index];
    } else {
        //id newItem = [currentSelectedItemDict objectForKey:item];
        if ([item isKindOfClass:[NSArray class]]) {
            if ([item count]) {
                return [item objectAtIndex:index];
            }
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            if ([item count]) {
                return [[item allValues] objectAtIndex:index];
            }
        }
        return item;
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    //id newItem = [currentSelectedItemDict objectForKey:item];
    if ([item isKindOfClass:[NSArray class]]) {
        if ([item count] > 0) {
            return YES;
        }
    } else if ([item isKindOfClass:[NSDictionary class]]) {
        if ([[item allKeys] count] > 0) {
            return YES;
        }
    }
    return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
         // root
         //NSLog(@"%@", currentSelectedItemDict);
        return [[currentSelectedItemDict allKeys] count];
    } else {
        //id newItem = [currentSelectedItemDict objectForKey:item];

    if ([item isKindOfClass:[NSArray class]] || [item isKindOfClass:[NSDictionary class]]) {
            return [item count];
        }
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if (tableColumn == keyColumn) {
        id parentObject = (id)NSMapGet(_parentMap, item);

        if (!parentObject) {
            parentObject = currentSelectedItemDict;
        }

        if ([parentObject isKindOfClass:[NSArray class]]) {
            return [NSNumber numberWithInt:[parentObject indexOfObject:item]];
        }
        if ([parentObject isKindOfClass:[NSDictionary class]]) {
//            int index = [[parentObject allValues] indexOfObject:item];
//            NSString *val = [[parentObject allKeys] objectAtIndex:index];

			id obj = (id)NSMapGet(_keyMap, item);
            return obj;
        }

        return item;
    } if (tableColumn == typeColumn) {
        // Return an NSNumber with the index of the selected item in the popup of classes.
        id obj = @"";

        if ([item isKindOfClass:[NSDictionary class]]) {
                obj = NSLocalizedString(@"Dictionary", @"");
        } else if ([item isKindOfClass:[NSArray class]]) {
                obj = NSLocalizedString(@"Array", @"");
        } else if ([item isKindOfClass:[NSString class]]) {
                obj = NSLocalizedString(@"String", @"");
        } else if ([item isKindOfClass:[NSData class]]) {
                obj = NSLocalizedString(@"Data", @"");
        } else if ([item isKindOfClass:[NSDate class]]) {
                obj = NSLocalizedString(@"Date", @"");
        } else if ([item isKindOfClass:[RBool class]]) {
                obj = NSLocalizedString(@"Boolean", @"");
        } else if ([item isKindOfClass:[NSNumber class]]) {
                obj = NSLocalizedString(@"Number", @"");
        }
        return obj;
    } else {

        if ([item isKindOfClass:[NSArray class]]) {
                if ([item count] == 1) {
                        return [NSString stringWithFormat:NSLocalizedString(@"(%d Object)", @""), [item count]];
                } else {
                        return [NSString stringWithFormat:NSLocalizedString(@"(%d Objects)" ,@""), [item count]];
                }
        } else if ([item isKindOfClass:[NSDictionary class]]) {
                if ([item count] == 1) {
                        return [NSString stringWithFormat:NSLocalizedString(@"(%d Key/Value Pair)", @""), [item count]];
                } else {
                        return [NSString stringWithFormat:NSLocalizedString(@"(%d Key/Value Pairs)", @""), [item count]];
                }
        } else if ([item isKindOfClass:[NSData class]]) {
            return [self CFDataShow:(CFDataRef)item];
        } else if ([item isKindOfClass:[NSNumber class]]) {
            long long val = [item longLongValue];
            return [NSString stringWithFormat:@"%s (%#qx)", [[item description] UTF8String], val];
        }
        
        return [item description];
    }
    return @"";
}

- (int) splitInplaceStringIntoMultipleLinesAtSpaces:(NSMutableString *)inString
// Takes the given mutable string and very crudely modifies it if needed in-place to be folded into multiple lines.
// It does so by replacing space characters with a newline character every while or so, thus making the assumption that there
// are plenty of spaces periodically.  The number of times this is done (ie, the number of extra lines created) is returned.
{
	int			outNumReplacementsDone = 0;
	NSRange		aRange;
	int			theLength = [inString length];
	int			index;
	int			thisLineCharCount = 0;
	
	for (index = 0;   index < theLength;   index++)
	{
		thisLineCharCount++;
		if (thisLineCharCount > 70)
		{
			if (' ' == [inString characterAtIndex:index])
			{
				aRange.location = index;
				aRange.length = 1;
				[inString replaceCharactersInRange:aRange withString:@"\n"];
				thisLineCharCount = 0;
				outNumReplacementsDone++;
			}
		}
	}
	
	return outNumReplacementsDone;
}

- (NSString *)outlineView:(NSOutlineView *)inOutlineView toolTipForCell:(NSCell *)inCell rect:(NSRectPointer)inRect tableColumn:(NSTableColumn *)inTableColumn item:(id)inItem mouseLocation:(NSPoint)inMouseLocation
// Tool tip callback (delegate): Show tool tip for data item only for now.
{
	return [inItem description];
}

- (float)outlineView:(NSOutlineView *)inOutlineView heightOfRowByItem:(id)inItem
// Row height callback (delegate): Return normal value for everything except data items, in which case it returns a bigger
// value to accommodate the extra number of text lines that are being output from CFDataShow.
{
	if (YES == [inItem isKindOfClass:[NSData class]])
	{
		int				numNewlinesInStr = 0;
		NSString *		peekStr = [self CFDataShow:(CFDataRef)inItem];
		int				peekLen = [peekStr length];
		int				index;
		
		for (index = 0;   index < peekLen;   index++)
			if ('\n' == [peekStr characterAtIndex:index]) numNewlinesInStr++;
		
		return 14.0 * (1 + numNewlinesInStr);
	}
	else
	{
		return 14.0;
	}
}

- (NSString *)CFDataShow:(CFDataRef)object
{
	if (YES == _dataTypeViewTraditional)
	{
		return [self CFDataShowAsAutomaticAsciiOrUntypedData:object];
	}
	else
	{
		NSMutableString *		formattedStrWithNewlines;
		NSString *				formattedStr =
							[self CFDataShowAsScalars:	object
								asDatumSizesInBytes:	_dataTypeViewByteSize
								asBigEndians:			_dataTypeViewIsBigEndian
								asRadixes:				_dataTypeViewRadix
								asNSStringEncodings:	_dataTypeViewEncoding
								showHeader:				YES
								showBetweenSeparators:	@" "
								showStartSeparator:		@"<"
								showEndSeparator:		@">"];
		formattedStrWithNewlines  = [NSMutableString stringWithString:formattedStr];
		[self splitInplaceStringIntoMultipleLinesAtSpaces:formattedStrWithNewlines];
		return formattedStrWithNewlines;
	}
}

- (NSString *)CFDataShowAsAutomaticAsciiOrUntypedData:(CFDataRef)object
{
    UInt32        asciiNormalCount = 0;
    UInt32        asciiSymbolCount = 0;
    const UInt8 * bytes;
    CFIndex       index;
    CFIndex       length;

    NSMutableString *newString = [NSMutableString string];

    [newString appendString:@"<"];
    length = CFDataGetLength(object);
    bytes  = CFDataGetBytePtr(object);

    //
    // This algorithm detects ascii strings, or a set of ascii strings, inside a
    // stream of bytes.  The string, or last string if in a set, needn't be null
    // terminated.  High-order symbol characters are accepted, unless they occur
    // too often (80% of characters must be normal).  Zero padding at the end of
    // the string(s) is valid.  If the data stream is only one byte, it is never
    // considered to be a string.
    //

    for (index = 0; index < length; index++)  // (scan for ascii string/strings)
    {
        if (bytes[index] == 0)       // (detected null in place of a new string,
        {                            //  ensure remainder of the string is null)
            for (; index < length && bytes[index] == 0; index++) { }

            break;          // (either end of data or a non-null byte in stream)
        }
        else                         // (scan along this potential ascii string)
        {
            for (; index < length; index++)
            {
                if (isprint(bytes[index]))
                    asciiNormalCount++;
                else if (bytes[index] >= 128 && bytes[index] <= 254)
                    asciiSymbolCount++;
                else
                    break;
            }

            if (index < length && bytes[index] == 0)          // (end of string)
                continue;
            else             // (either end of data or an unprintable character)
                break;
        }
    }

    if ((asciiNormalCount >> 2) < asciiSymbolCount)    // (is 80% normal ascii?)
        index = 0;
    else if (length == 1)                                 // (is just one byte?)
        index = 0;

    if (index >= length && asciiNormalCount) // (is a string or set of strings?)
    {
        Boolean quoted = FALSE;

        for (index = 0; index < length; index++)
        {
            if (bytes[index])
            {
                if (quoted == FALSE)
                {
                    quoted = TRUE;
                    if (index)
                        [newString appendString:@",\""];
                    else
                        [newString appendString:@"\""];
                }
                [newString appendFormat:@"%c", bytes[index]];
            }
            else
            {
                if (quoted == TRUE)
                {
                    quoted = FALSE;
                    [newString appendString:@"\""];
                }
                else
                    break;
            }
        }
        if (quoted == TRUE)
            [newString appendString:@"\""];
    }
    else                                  // (is not a string or set of strings)
    {
        for (index = 0; index < length; index++)
            [newString appendFormat:@"%02x", bytes[index]];
    }

    [newString appendString:@">"];
    return [[newString copy] autorelease];
}

- (NSString *)CFDataShowAsScalars:(CFDataRef)inObject
							asDatumSizesInBytes:(int)inDatumSizesInBytes
							asBigEndians:(BOOL)inBigEndians
							asRadixes:(int)inRadixes
							asNSStringEncodings:(int)inNSStringEncodings
							showHeader:(BOOL)inHeader
							showBetweenSeparators:(NSString *)inBetweenSeparators
							showStartSeparator:(NSString *)inStartSeparator
							showEndSeparator:(NSString *)inEndSeparator
//
// This routine returns an NSString representation of the data in the given CFDataRef object, subject to the given
// constraints on the interpretation of each data item.  See CFDatumShowAsScalar for details.  As many whole data items
// as there are bytes for are emitted.  For example, if the given object data length is 18-bytes and we are asked to show
// as 2-byte quantities (often called shorts), a string with 9 substrings, possibly separated with spaces and/or prepended
// with radix identifier substrings, will be returned.  A special substring is emitted if there are bytes "left over",
// that is, if the given object's data length is not an integer multiple of the datum size-in-bytes.
//
{
    const UInt8 *			allData;
    CFIndex					allDataIndex;
    CFIndex					allDataLength;
	BOOL					isEndOfAllData;
	
	NSMutableArray *		oneDatum = [NSMutableArray arrayWithCapacity:100];
    CFIndex					oneDatumIntraIndex;
	UInt8					oneByteInsideDatum;
	BOOL					isEndOfOneDatum;
	
	BOOL					notYetOutputADatum;
    NSMutableString *		outString = [NSMutableString string];
	
    allDataLength = CFDataGetLength (inObject);
    allData = CFDataGetBytePtr (inObject);
	
	allDataIndex = 0;
	oneDatumIntraIndex = 0;
	notYetOutputADatum = YES;
	
	// Emit preamble with optional format header and caller-supplied start-of-data marker:
	//
	if (YES == inHeader)
	{
		if (1 == allDataLength)
		{
			[outString appendString:NSLocalizedString(@"(1 Byte) ", @"")];
		}
		else
		{
			[outString appendFormat:NSLocalizedString(@"(%d Bytes) ", @""), allDataLength];
		}
		[outString appendFormat:NSLocalizedString(@"as ", @"")];
		[outString appendFormat:NSLocalizedString(@"%d-bit ", @""), (inDatumSizesInBytes * 8)];
		if (inDatumSizesInBytes > 1) 
		{
			[outString appendString: inBigEndians ?
				NSLocalizedString(@"big-endian ", @"") :
				NSLocalizedString(@"little-endian ", @"")];
		}
		switch (inRadixes)
		{
		case 0:
			switch (inNSStringEncodings)
			{
			case NSASCIIStringEncoding:			[outString appendString:NSLocalizedString(@"ASCII char ", @"")];								break;
			case NSMacOSRomanStringEncoding:	[outString appendString:NSLocalizedString(@"MacRoman char ", @"")];								break;
			case NSUTF8StringEncoding:			[outString appendString:NSLocalizedString(@"UTF-8 char ", @"")];								break;
			case NSUnicodeStringEncoding:		[outString appendString:NSLocalizedString(@"Unicode char ", @"")];								break;
			default:							[outString appendFormat:NSLocalizedString(@"char encoding %d ", @""), inNSStringEncodings];		break;
			}
		break;
		case 1:		[outString appendString:NSLocalizedString(@"unary ", @"")];					break;
		case 2:		[outString appendString:NSLocalizedString(@"binary ", @"")];				break;
		case 8:		[outString appendString:NSLocalizedString(@"octal ", @"")];					break;
		case 10:	[outString appendString:NSLocalizedString(@"decimal ", @"")];				break;
		case 16:	[outString appendString:NSLocalizedString(@"hex ", @"")];					break;
		default:	[outString appendFormat:NSLocalizedString(@"base %d ", @""), inRadixes];	break;
		}
		int numItems = (allDataLength / inDatumSizesInBytes);
		if (1 == numItems) 
		{
			[outString appendString:NSLocalizedString(@"(1 Item) ", @"")];
		}
		else
		{
			[outString appendFormat:NSLocalizedString(@"(%d Items) ", @""), numItems];
		}
	}
    [outString appendString:inStartSeparator];
	
	if (0 == allDataLength)
	{}
	else
	{
		for (;;)
		{
			// In an endian-agnostic way (no matter which way this code is compiled), consider the next N
			// bytes of the given object to be added into the datum array, earliermost bytes of data going into
			// earliermost bytes of datum array; also set boolean flag upon all-data-end:
			//
			isEndOfAllData = NO;
			oneByteInsideDatum = allData [allDataIndex];
			allDataIndex++;
			if (allDataIndex == allDataLength) isEndOfAllData = YES;
			
			// Finish doing the above; also set boolean flag upon one-datum-end:
			//
			isEndOfOneDatum = NO;
			[oneDatum addObject:[NSNumber numberWithChar:oneByteInsideDatum]];
			oneDatumIntraIndex++;
			if (oneDatumIntraIndex == inDatumSizesInBytes) isEndOfOneDatum = YES;
			
			// If end of a single datum item then emit it to output string and continue this main loop:
			//
			if (YES == isEndOfOneDatum)
			{
				// Append to output: Prepend (to separate) data items with (usually spaces) but not the first time:
				if (YES == notYetOutputADatum)
				{
					notYetOutputADatum = NO;
				}
				else
				{
					[outString appendString:inBetweenSeparators];
				}
				
				// Append to output: Append one datum item (one presentable-number or one character-cluster) with the
				// passed-in-to-us options and clear datum for next one:
				[outString appendString:
					[self	CFDatumShowAsScalar:	(NSArray *) oneDatum
							asBigEndian:			inBigEndians
							asRadix:				inRadixes
							asEncoding:				inNSStringEncodings
							asBitSize:				0]];
				oneDatumIntraIndex = 0;
				[oneDatum removeAllObjects];
			}
			
			// If end of total data then we will exit this entire loop, but first, if we had a partial
			// unfinished datum here at the end, so indicate:
			//
			if (YES == isEndOfAllData)
			{
				if (NO == isEndOfOneDatum)
				{
					[outString appendString:@"..."];
				}
				
				break;
			}
		}
	}
	
	// Emit caller-supplied postamble and return a copy for client use:
	//
    [outString appendString:inEndSeparator];
    return [[outString copy] autorelease];
}

- (NSString *)CFDatumShowAsScalar:(NSArray *)inDatum
							asBigEndian:(BOOL)inBigEndian
							asRadix:(int)inRadix
							asEncoding:(int)inEncoding
							asBitSize:(int)inBitSize
//
// This routine returns a string of the bytes in the given object, interpreted as a simple scalar quantity, with
// the given options.  The attempt here is to make the prototype of this routine complete; by no means are all
// (possibly bizarre) implications of input parameters supported.
//
// CFDatumShowAsScalar input: An NSArray of data bytes; the length of the array would be, ie, 1 for an 8-bit quantity,
// 2 for a 16-bit quantity, 4 for a 32-bit quantity, 8 for a 64-bit quantity, etc.  Note that for a character it will
// be of length 1 or 2.
//
// asBigEndian: If Big Endian is TRUE then earlier bytes have more significance (Motorola 68000-style),
// if FALSE earlier bytes have less (Intel-style).
//
// asRadix: Radix (number base) in which to show the datum item: 0=string, 1=unary (tick marks), 2=binary, 8=octal,
// 10=decimal, 16=hex, or arbitrary.
//
// asEncoding: Ignored for a number, but for a character, this is the string encoding (plain ASCII, UTF-8, MacRoman, etc)
// as per the NSStringEncoding (not CF) constants.
//
// asBitSize: Pass 0 to use the bit size as implied by the length of the given datum NSArray (that is, if 4 bytes are
// given then the bit size is taken to be 32-bits); if nonzero then consider an arbitrary number of bits.
//
{
	// Initialize to show non-result in case we are unable to do the conversion:
	//
    NSMutableString *		outString = NULL;
	
	// Variables for specified-endian scanning of given multibyte datum:
	//
	CFIndex					srcByteLen = [inDatum count];
	CFIndex					srcByteIndexEndianSensitive;
	UInt8					srcByte;
	long long				acc64ByteInsertPlaceValue;
	long long				acc64;
	int						workaroundPowerAssignBug;
	int						numBitsToShow;
	
	// Do specified-endian scanning of given multibyte datum; leave native result in "acc64":
	//
	acc64 = 0LL;
	if (YES == inBigEndian) { srcByteIndexEndianSensitive = 0; } else { srcByteIndexEndianSensitive = srcByteLen - 1; }
	
	acc64ByteInsertPlaceValue = 1;
	for (workaroundPowerAssignBug = 0;   workaroundPowerAssignBug < (srcByteLen - 1);   workaroundPowerAssignBug++)
		acc64ByteInsertPlaceValue *= 256;
	
	for (;;)
	{
		srcByte = [[inDatum objectAtIndex:srcByteIndexEndianSensitive] charValue];
		acc64 += (srcByte * acc64ByteInsertPlaceValue);
		acc64ByteInsertPlaceValue >>= 8;
		if (YES == inBigEndian)
		{
			srcByteIndexEndianSensitive++;
			if (srcByteLen == srcByteIndexEndianSensitive) break;
		}
		else
		{
			srcByteIndexEndianSensitive--;
			if (-1 == srcByteIndexEndianSensitive) break;
		}
	}
	
	// Decide how many bits we will be showing:
	//
	numBitsToShow = srcByteLen * 8;
	if (0 != inBitSize) numBitsToShow = inBitSize;
	
	// Case-by-case rendering of datum to string; if this section is unable to claim to handle it, it is left NULL.
	// We start with acc64, end up maybe setting outString, and for how to do it, we consider the quartet of
	// acc64 (the value), inRadix (the number base to show as), numBitsToShow (the number of bits in value), and
	// inEncoding (for chars).  At this point, endian is no longer an issue:
	//
	if (0 == inRadix)											// Try To Render As: Character
	{
		char cs[4]; 
		cs[0] = (char) (acc64  & 0xff);
		cs[1] = '\0';
		cs[2] = '\0';
		cs[3] = '\0';
		if (8 == numBitsToShow)
		{
			if ('\0' == cs[0])
			{
																outString = [NSString stringWithString:@"\\0"];   // show string terminator
			}
			else
			{
				if (NSASCIIStringEncoding == inEncoding)		outString = [NSString stringWithCString:cs encoding:NSASCIIStringEncoding];
				if (NSMacOSRomanStringEncoding == inEncoding)	outString = [NSString stringWithCString:cs encoding:NSMacOSRomanStringEncoding];
				if (NSUTF8StringEncoding == inEncoding)			outString = [NSString stringWithCString:cs encoding:NSUTF8StringEncoding];
			}
		}
		if (16 == numBitsToShow)
		{
			cs[1] = (char) ((acc64 >> 8) & 0xff);
			if (('\0' == cs[0]) && ('\0' == cs[1]))
			{
																outString = [NSString stringWithString:@"\\0\\0"];   // show string terminator
			}
			else
			{
				if (NSUnicodeStringEncoding == inEncoding)		outString = [NSString stringWithCString:cs encoding:NSUnicodeStringEncoding];
			}
		}
	}
	if (1 == inRadix)											// Try To Render As: Tick Marks
	{
		int i;
		if (acc64 <= 100)
		{
																outString = [NSMutableString string];
			for (i = 1;   i <= acc64;   i++)					[outString appendString:@"*"];
		}
	}
	if (2 == inRadix)											// Try To Render As: Binary
	{
		int i;
		UInt64 j = acc64;
																outString = [NSMutableString string];
		for (i = 0;   i < numBitsToShow;   i++)
		{
			if (0 == (j & 1))									[outString insertString:@"0" atIndex:0];
			else												[outString insertString:@"1" atIndex:0];
			j >>= 1;
		}
																[outString insertString:@"0b" atIndex:0];
	}
	if (8 == inRadix)											// Try To Render As: Octal
	{
		if (0 == acc64)
		{
																outString = [NSString stringWithString:@"0"];
		}
		else
		{
			if (numBitsToShow <= 32)							outString = [NSString stringWithFormat:@"0%o", (UInt32) acc64];
			if (numBitsToShow > 32)								outString = [NSString stringWithFormat:@"0%llo", (UInt64) acc64];
		}
	}
	if (10 == inRadix)											// Try To Render As: Decimal
	{
		if (numBitsToShow <= 32)								outString = [NSString stringWithFormat:@"%u", (UInt32) acc64];
		if (numBitsToShow > 32)									outString = [NSString stringWithFormat:@"%llu", (UInt64) acc64];
	}
	if (16 == inRadix)											// Try To Render As: Hexadecimal
	{
		if (4 == numBitsToShow)									outString = [NSString stringWithFormat:@"0x%1x", (UInt8) acc64];
		if (8 == numBitsToShow)									outString = [NSString stringWithFormat:@"0x%02x", (UInt8) acc64];
		if (16 == numBitsToShow)								outString = [NSString stringWithFormat:@"0x%04x", (UInt16) acc64];
		if (32 == numBitsToShow)								outString = [NSString stringWithFormat:@"0x%08x", (UInt32) acc64];
		if (64 == numBitsToShow)								outString = [NSString stringWithFormat:@"0x%016llx", (UInt64) acc64];
		if (NULL == outString)									outString = [NSString stringWithFormat:@"0x%016llx", (UInt64) acc64];
	}
	
	// Emit caller-supplied postamble and return a copy for client use; it will be placeholder char if we were unable:
	//
	if (NULL == outString) outString = [NSString stringWithString:@"?"];
	return [[outString copy] autorelease];
}


@end
