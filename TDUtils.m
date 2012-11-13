#import "TDUtils.h"
#import <objc/runtime.h>

@implementation TDUtils


static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

#pragma mark - Get properties for a class
+ (NSDictionary *)propertiesForClass:(Class)cls
{
    if (cls == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}


+ (id)objectWithClass:(Class)cls fromDictionary:(NSDictionary *)dict {
    id obj = [[[cls alloc] init] autorelease];
    
    NSDictionary* properties = [TDUtils propertiesForClass:cls];
    
    // Since key of object is a string, we need to check the dict contains
    // string as key. If it contains non-string key, the key will be skipped.
    // If key is not inside the object properties, it's skipped too.
    // Otherwise assign value of key from dict to obj
    for (id key in dict) {
        // Skip for non-string key
        if ([key isKindOfClass:[NSString class]] == NO) {
            NSLog(@"TDUtils: key must be NSString. Received key %@", key);
            break;
        }
        
        // If key is not inside the object properties, skip it
        id value = [properties objectForKey:key];
        if (value == nil) {
            NSLog(@"TDUtils: key %@ is not existed in class %@", key, NSStringFromClass(cls));
            break;
        }
        
        // For string-key
        [obj setValue:value forKey:key];
    }
    
    return obj;
}

+(NSArray *)arrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray *)array {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    
    for (id item in array) {
        // The item must be a dictionary. Otherwise, skip it
        if ([item isKindOfClass:[NSDictionary class]] == NO) {
            NSLog(@"TDUtils: item inside array must be NSDictionary object");
            break;
        }
        
        // Convert item dictionary to object with predefined class
        id obj = [TDUtils objectWithClass:cls fromDictionary:item];
        [mutableArray addObject:obj];
    }
    
    NSArray *arrWithClass = [NSArray arrayWithArray:mutableArray];
    [mutableArray release];
    return arrWithClass;
}


#pragma mark - Validate Emails
+ (BOOL)validateEmail:(NSString *)email {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

@end
