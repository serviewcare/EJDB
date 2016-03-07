#import <Cordova/CDV.h>

@interface EJDBPlugin : CDVPlugin

- (CDVPluginResult*) createDatabaseWithPath:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) initializeCollectionWithName:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) saveObject:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) maxDate:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) find:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) remove:(CDVInvokedUrlCommand*)command;

@end
