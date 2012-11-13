TDUtils
=======

Many of these utilities come from StackOverflow or other sources. You can always take a look at original URL.


### 1) + (NSDictionary *)propertiesForClass:(Class)cls;

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


### 2) + (id) objectWithClass:(Class)cls fromDictionary:(NSDictionary*)dict;

Convert a dict to an object with predefined class. Useful for translate server json to object.


### 3) + (NSArray*) arrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray*)array;

Convert an array of dict to array of object with predefined class. Useful for translate server json to object.


### 4) + (BOOL) validateEmail:(NSString*)email;

Validate email using Regex. Answer from http://stackoverflow.com/questions/800123/best-practices-for-validating-email-address-in-objective-c-on-ios-2-0