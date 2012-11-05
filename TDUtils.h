#import <Foundation/Foundation.h>

@interface TDUtils : NSObject

/**
 Answer from http://stackoverflow.com/questions/754824/get-an-object-attributes-list-in-objective-c/13000074#13000074
 
 Return dictionary of property name and type from a class.
 Useful for Key-Value Coding. For example:
 
     - (void)encodeWithCoder:(NSCoder *)encoder {
         //Encode properties, other class variables, etc
         NSDictionary* propertyDict = [Utils propertiesForClass:[self class]];
 
         for (NSString* key in propertyDict) {
             id value = [self valueForKey:key];
             [encoder encodeObject:value forKey:key];
         }
     }
 
     - (id)initWithCoder:(NSCoder *)decoder {
         if((self = [super init])) {
         //decode properties, other class vars
             NSDictionary* propertyDict = [Utils propertiesForClass:[self class]];
 
             for (NSString* key in propertyDict) {
                 id value = [decoder decodeObjectForKey:key];
                 [self setValue:value forKey:key];
             }
         }
         return self;
     }
 */
+ (NSDictionary *)propertiesForClass:(Class)cls;

/** Validate email using Regex
 Answer from http://stackoverflow.com/questions/800123/best-practices-for-validating-email-address-in-objective-c-on-ios-2-0
 */
+ (BOOL) validateEmail:(NSString*)email;

@end
