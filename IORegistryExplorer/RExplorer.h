#import <AppKit/AppKit.h>

#import <IOKit/IOKitLib.h>

#import "RBool.h"

@interface RExplorer : NSObject
{
    id						browser;
    id						window;
    id						planeWindow;
    id						inspectorWindow;
	id						menuDataTypeView;

    id						inspectorText;
    id						informationView;  // NSTextView ?

    id						splitView;
    id						propertiesOutlineView;

    id						keyColumn;
    id						typeColumn;
    id						valueColumn;

    id						updatePrefsMatrix;

    id						objectDescription;
    id						objectDescription2;
    id						objectState;
    id						objectInheritance;

    NSDictionary *			currentSelectedItemDict;
    NSDictionary *			aboutBoxOptions;

    int						trackingRect;

    NSDictionary *			registryDict;

    NSString *				currentLocation;
    int						currentLevel;  // where are we at the current level ?
    id						planeBrowser;
    const char *			currentPlane;

    NSMapTable *			_parentMap;
    NSMapTable *			_keyMap;

    int						autoUpdate;
    NSTimer *				updateTimer;
	mach_port_t				_machPort;
    IONotificationPortRef	_notifyPort;
    Boolean					_registryHasChanged;
    BOOL					dialogDisplayed;
    Boolean					_registryHasQuieted;
	
	BOOL					_dataTypeViewTraditional;
	int						_dataTypeViewByteSize;
	BOOL					_dataTypeViewIsBigEndian;
	int						_dataTypeViewRadix;
	int						_dataTypeViewEncoding;
}

- (void)changeLevel:(id)sender;

- (void)initializeRegistryDictionaryWithPlane:(const char *)plane;
- (NSDictionary *)dictForIterated:(io_registry_entry_t)passedEntry;
- (NSArray *)childArrayAtColumn:(int)column;
- (NSDictionary *) propertiesForRegEntry:(NSDictionary *)object;

- (void)dumpDictionaryToOutput:(id)sender;

- (void)displayAboutWindow:(id)sender;

- (void)switchRootPlane:(id)sender;
- (void)displayPlaneWindow:(id)sender;

- (void)initializeMapsForDictionary:(NSDictionary *)dict;

- (void)checkForUpdate:(NSTimer *)timer;

- (void)forceUpdate:(id)sender;

- (void)registryHasChanged;

- (void)goToPath:(NSString *)path;

- (NSArray *)searchResultsForText:(NSString *)text searchKeys:(BOOL)keys searchValues:(BOOL)values;

- (NSArray *)searchKeysResultsInDictionary:(NSDictionary *)dict forText:(NSString *)text passedPath:(NSString *)path;

- (void)updatePrefs:(id)sender;

- (NSString *)createInheritanceStringForIORegistryClassName:(NSString *)inClassName;

- (void)menuItemTurnOffPeerRangeThenTurnItOn:(id)inMenuItem rangeBegin:(int)inRangeBegin rangeEnd:(int)inRangeEnd;
- (void)menuItemSetEnablePeerRange:(id)inMenuItem rangeBegin:(int)inRangeBegin rangeEnd:(int)inRangeEnd enable:(BOOL)inEnable;

- (void)menuDataTypeViewItemTraditional:(id)sender;
- (void)menuDataTypeViewItem8Bit:(id)sender;
- (void)menuDataTypeViewItem16Bit:(id)sender;
- (void)menuDataTypeViewItem32Bit:(id)sender;
- (void)menuDataTypeViewItem64Bit:(id)sender;
- (void)menuDataTypeViewItemBigEndian:(id)sender;
- (void)menuDataTypeViewItemLittleEndian:(id)sender;
- (void)menuDataTypeViewItemUnary:(id)sender;
- (void)menuDataTypeViewItemBinary:(id)sender;
- (void)menuDataTypeViewItemOctal:(id)sender;
- (void)menuDataTypeViewItemDecimal:(id)sender;
- (void)menuDataTypeViewItemHexadecimal:(id)sender;
- (void)menuDataTypeViewItemASCII:(id)sender;
- (void)menuDataTypeViewItemMacRoman:(id)sender;
- (void)menuDataTypeViewItemUTF8:(id)sender;
- (void)menuDataTypeViewItemUnicode:(id)sender;

@end
