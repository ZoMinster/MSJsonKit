//
//  MSJsonKit.m
//
//
//  Created by Minster on 14/10/20.
//
//

#import "MSJsonKit.h"
#import "objc/runtime.h"

static NSString *re = @"(?<=T@\")(.*)(?=\",)";
@implementation MSJsonKit

/**
 * obj 转 json
 * @param obj
 * @param jsonAddr
 */
+(void)objToJson: (id)obj  out: (NSMutableString **)jsonAddr withKey: (NSString *)key{
    NSMutableString *json = *jsonAddr;
    //初始化json
    if (json == nil) {
        json = [[NSMutableString alloc] init];
    }
    //是否有额外key
    BOOL flag = false;
    if (key != nil) {
        if (json.length == 0) {
            [json appendFormat: @"{\"%@\":", key];
            flag = true;
        } else {
            [json appendFormat: @"\"%@\":", key];
        }
    }
    if (obj == nil) {
        //如果为空
        [json appendString: [MSJsonKit getNullJsonWithKey: nil]];
    } else if ([obj isKindOfClass: [NSArray class]]) {
        //如果是数组
        [json appendString: @"["];
        NSArray *arr = (NSArray *)obj;
        for (int i = 0; i < arr.count; i++) {
            if (i != 0) {
                [json appendString: @","];
            }
            [MSJsonKit objToJson: arr[i] out: &json withKey: nil];
        }
        [json appendString: @"]"];
    } else if ([obj isKindOfClass: [NSDictionary class]]) {
        //如果是字典
        [json appendString: @"{"];
        int i = 0;
        for (NSString *keyName in obj) {
            if (i != 0) {
                [json appendString: @","];
            }
            [MSJsonKit objToJson: obj[keyName] out: &json withKey: keyName];
            i++;
        }
        [json appendString: @"}"];
    } else if ([obj isKindOfClass: [NSString class]]) {
        //如果是字符串
        [json appendString: [MSJsonKit getStringJson: (NSString *)obj withKey: nil]];
    } else if ([obj isKindOfClass: [NSNumber class]]) {
        //如果是数字
        [json appendString: [MSJsonKit getNumberJson: (NSNumber *)obj withKey: nil]];
    } else if ([obj isKindOfClass: [NSDate class]]) {
        //如果是日期
        [json appendString: [MSJsonKit getDateJson: (NSDate *)obj withKey: nil]];
    } else if ([obj isKindOfClass: [NSNull class]]) {
        //如果为空类
        [json appendString: [MSJsonKit getNullJsonWithKey: nil]];
    } else if ([obj isKindOfClass: [NSObject class]]) {
        //如果是一个自定义类
        
        
        
        [json appendString: @"{"];
        
        unsigned int outCount;
        
        objc_property_t *props = class_copyPropertyList([obj class], &outCount);
        
        
        for (int i = 0; i < outCount; i++) {
            if (i != 0) {
                [json appendString: @","];
            }
            objc_property_t prop = props[i];
            NSString *propName = [[NSString alloc] initWithCString: property_getName(prop) encoding: NSUTF8StringEncoding];
            id value = [obj valueForKey: propName];
            if ([[obj class] conformsToProtocol: @protocol(MSJsonSerializing)]) {
                NSDictionary *jsonKeyPathsOfProp = [[obj class] JsonKeyPathsByPropertyKey];
                if (jsonKeyPathsOfProp != nil && [[jsonKeyPathsOfProp allKeys] containsObject: propName]) {
                    propName = [jsonKeyPathsOfProp objectForKey: propName];
                }
            }
            [MSJsonKit objToJson: value out: &json withKey: propName];
#ifdef DEBUG
            NSLog(@"key: %@", propName);
#endif
            
        }
        
        [json appendString: @"}"];
    }
    
    if (flag == true) {
        [json appendString: @"}"];
    }
    
    *jsonAddr = json;
}

/**
 *  obj 转 json
 *
 *  @param obj obj
 *  @param key key
 */
+(NSString *)objToJson: (id)obj withKey: (NSString *)key {
    NSMutableString *json = nil;
    [MSJsonKit objToJson: obj out: &json withKey: key];
    return json;
}

/**
 * json 转 obj
 * @param json
 * @param mclass
 * @result (id)
 */
+(id)jsonToObj: (NSString *)json asClass: (Class)mclass  {
    return [MSJsonKit jsonToObj: json asClass: mclass WithKeyClass: nil];
}

/**
 * json 转 obj
 * @param json
 * @param mclass
 * @param keyClass
 * @result (id)
 */
+(id)jsonToObj:(NSString *)json asClass:(Class)mclass WithKeyClass: (NSDictionary *) keyClass {
    //id obj = nil;
    //初始化对象
    //obj = [[mclass alloc] init];
    //将json转化为字典
    NSError *error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding: NSUTF8StringEncoding] options: kNilOptions error: &error];
    
    if (jsonObj == nil) {
        return jsonObj;
    }
#ifdef DEBUG
    NSLog(@"JSON:\n%@", jsonObj);
#endif
    
    
    return [MSJsonKit jsonObjToObj: jsonObj asClass: mclass WithKeyClass: keyClass ForKey: @"msroot"];
}

/**
 * jsonObj 转 obj
 * @param json 需转化的json字符串
 * @param mclass  需转化成的objc类
 * @param keyClass 如果有某个objc类属性为NSArray或者NSDictionay, 可以传入@{@"asdf"(该属性键): (数组每项的类型或者字典每个值的类型),....},否则传nil
 *
 * @result (id) 转化后的objc对象
 */
+(id)jsonObjToObj: (id)jsonObj asClass:(Class)mclass WithKeyClass: (NSDictionary *) keyClass {
    if (jsonObj == nil) {
        return jsonObj;
    }
#ifdef DEBUG
    NSLog(@"JSON:\n%@", jsonObj);
#endif
    
    
    return [MSJsonKit jsonObjToObj: jsonObj asClass: mclass WithKeyClass: keyClass ForKey: @"msroot"];
}
/**
 * jsonObj 转 obj
 * @param json 需转化的json字符串
 * @param mclass  需转化成的objc类
 * @param keyClass 如果有某个objc类属性为NSArray或者NSDictionay, 可以传入@{@"asdf"(该属性键): (数组每项的类型或者字典每个值的类型),....},否则传nil
 *
 * @result (id) 转化后的objc对象
 */
+(id)jsonObjToObj: (id)jsonObj asClass:(Class)mclass {
    if (jsonObj == nil) {
        return jsonObj;
    }
#ifdef DEBUG
    NSLog(@"JSON:\n%@", jsonObj);
#endif
    
    
    return [MSJsonKit jsonObjToObj: jsonObj asClass: mclass WithKeyClass: nil ForKey: @"msroot"];
}



+(id)jsonObjToObj: (id)jsonObj asClass:(Class)mclass WithKeyClass: (NSDictionary *) keyClass ForKey:(NSString *)keyName {
    
    id obj;
    
    if (jsonObj != nil) {
        
        if ([mclass isSubclassOfClass: [NSDictionary class]] && [jsonObj isKindOfClass: [NSDictionary class]]) {
            if (keyClass != nil && [keyClass.allKeys containsObject: keyName]) {
                mclass = (Class)(keyClass[keyName]);
            }
            NSDictionary *dic = (NSDictionary *)jsonObj;
            obj = [[NSMutableDictionary alloc] init];
            for (NSString *key in dic) {
                if ([dic[key] isKindOfClass: [NSArray class]]) { //[dic[key] isKindOfClass: [NSDictionary class]] ||
                    mclass = [dic[key] class];
                }
                [obj setObject: [MSJsonKit jsonObjToObj: dic[key] asClass: mclass WithKeyClass: keyClass ForKey:keyName] forKey: key];
            }
        } else if ([mclass isSubclassOfClass: [NSArray class]] && [jsonObj isKindOfClass: [NSArray class]]) {
            if (keyClass !=nil && [keyClass.allKeys containsObject: keyName]) {
                mclass = (Class)(keyClass[keyName]);
            }
            NSArray *arr = (NSArray *)jsonObj;
            obj = [[NSMutableArray alloc] init];
            for (int j = 0; j < arr.count; j++) {
                if ([arr[j] isKindOfClass: [NSArray class]]) { //[arr[j] isKindOfClass: [NSDictionary class]] ||
                    mclass = [arr[j] class];
                }
                [obj addObject: [MSJsonKit jsonObjToObj: arr[j] asClass: mclass WithKeyClass: keyClass ForKey:keyName]];
            }
        } else if ([mclass isSubclassOfClass: [NSDate class]]) {
            if ([jsonObj isKindOfClass: [NSNull class]]) {
                obj = nil;
            } else {
                obj = [NSDate dateWithTimeIntervalSince1970: [((NSNumber *)jsonObj) doubleValue]/1000];
            }
        } else if (![mclass isSubclassOfClass: [NSString class]] &&
                   ![mclass isSubclassOfClass: [NSNumber class]] &&
                   ![mclass isSubclassOfClass: [NSDictionary class]] &&
                   ![mclass isSubclassOfClass: [NSArray class]] &&
                   ![mclass isSubclassOfClass: [NSDate class]] &&
                   [mclass isSubclassOfClass: [NSObject class]]) {
            
            NSDictionary *dic = nil;
            if ([jsonObj isKindOfClass: [NSDictionary class]]) {
                dic = (NSDictionary *)jsonObj;
            } else if ([jsonObj isKindOfClass: [NSString class]]) {
                NSError *error = nil;
                dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [jsonObj dataUsingEncoding: NSUTF8StringEncoding] options: kNilOptions error: &error];
                if (error != nil) {
                    if ([jsonObj isKindOfClass: [NSNull class]]) {
                        obj = nil;
                    } else {
                        obj = jsonObj;
                    }
                    return obj;
                }
            } else {
                if ([jsonObj isKindOfClass: [NSNull class]]) {
                    obj = nil;
                } else {
                    obj = jsonObj;
                }
                return obj;
            }
            
            obj = [[mclass alloc] init];
            
            //遍历属性
            unsigned int outCount;
            
            objc_property_t *props = class_copyPropertyList(mclass, &outCount);
            
            
            for (int i = 0; i < outCount; i++) {
                objc_property_t prop = props[i];
                NSString *propName = [[NSString alloc] initWithCString: property_getName(prop) encoding: NSUTF8StringEncoding];
                NSString *dicPropName = [NSString stringWithString: propName];
                
                if ([[obj class] conformsToProtocol: @protocol(MSJsonSerializing)]) {
                    NSDictionary *jsonKeyPathsOfProp = [[obj class] JsonKeyPathsByPropertyKey];
                    if (jsonKeyPathsOfProp != nil && [[jsonKeyPathsOfProp allKeys] containsObject: propName]) {
                        dicPropName = [jsonKeyPathsOfProp objectForKey: propName];
                    }
                }
                NSString *propAttr = [[NSString alloc] initWithCString: property_getAttributes(prop) encoding: NSUTF8StringEncoding];
                if (propName == nil) {
                    continue;
                } else {
                    
                    NSRange range = [propAttr rangeOfString: re options: NSRegularExpressionSearch];
                    if ([dic.allKeys containsObject: dicPropName]) {
                        if (range.length != 0) {
                            NSString *propClassName = [propAttr substringWithRange: range];
                            
                            if ([dic.allKeys containsObject: dicPropName]) {
                                Class propClass = objc_getClass([propClassName UTF8String]);
                                [obj setValue: [MSJsonKit jsonObjToObj: dic[dicPropName] asClass: propClass WithKeyClass: keyClass ForKey: propName] forKey: propName];
                            }
                        } else {
                            [obj setValue: [MSJsonKit jsonObjToObj: dic[propName] asClass: [NSNumber class] WithKeyClass: keyClass ForKey: propName] forKey: propName];
                        }
                    }
                }
                
            }
        } else if ([jsonObj isKindOfClass: [NSNull class]]) {
            obj = nil;
        } else {
            obj = jsonObj;
        }
        
        
    }
    
    return obj;
}

+(NSString *)getStringJson: (NSString *)str withKey: (NSString *)key {
    if (key == nil) {
        return [NSString stringWithFormat: @"\"%@\"", [str stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""]];
    }
    return [NSString stringWithFormat: @"\"%@\":\"%@\"", key, [str stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""]];
}

+(NSString *)getNumberJson: (NSNumber *)num withKey: (NSString *)key {
    if (key == nil) {
        return [NSString stringWithFormat: @"%@", num];
    }
    return [NSString stringWithFormat: @"\"%@\":%@", key, num];
}
+(NSString *)getNullJsonWithKey: (NSString *)key {
    if (key == nil) {
        return @"null";
    }
    return [NSString stringWithFormat: @"\"%@\":%@", key, @"null"];
}
+(NSString *)getBoolJson: (BOOL)flag withKey: (NSString *)key {
    return @"";
}
+(NSString *)getDateJson: (NSDate *) date withKey: (NSString *)key {
    if (key == nil) {
        return [NSString stringWithFormat: @"%qi", (long long)([date timeIntervalSince1970]*1000)];
    }
    return [NSString stringWithFormat: @"\"%@\":%qi", key, (long long)([date timeIntervalSince1970]*1000)];
}

@end
