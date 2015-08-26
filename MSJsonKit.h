//
//  MSJsonKit.h
//  
//
//  Created by Minster on 14/10/20.
//  
//

#import <Foundation/Foundation.h>

@interface MSJsonKit : NSObject
/**
 * obj 转 json
 * @param obj
 * @param jsonAddr
 */
+(void)objToJson: (id)obj  out: (NSMutableString **)jsonAddr withKey: (NSString *)key;

/**
 *  obj 转 json
 *
 *  @param obj obj
 *  @param key key
 */
+(NSString *)objToJson: (id)obj withKey: (NSString *)key;
/**
 * json 转 obj
 * @param json
 * @param mclass
 * @result (id)
 */
+(id)jsonToObj: (NSString *)json asClass: (Class)mclass;
/**
 * json 转 obj
 * @param json
 * @param mclass
 * @param keyClass
 * @result (id)
 */
+(id)jsonToObj:(NSString *)json asClass:(Class)mclass WithKeyClass: (NSDictionary *) keyClass;
@end

@interface MSJsonKit(Private)
+(id)jsonObjToObj: (id)jsonObj asClass:(Class)mclass WithKeyClass: (NSDictionary *) keyClass ForKey: (NSString *)keyName;
+(NSString *)getStringJson: (NSString *)str withKey: (NSString *)key;
+(NSString *)getNumberJson: (NSNumber *)num withKey: (NSString *)key;
+(NSString *)getNullJsonWithKey: (NSString *)key;
+(NSString *)getBoolJson: (BOOL)flag withKey: (NSString *)key;
+(NSString *)getDateJson: (NSDate *) date withKey: (NSString *)key;
@end
