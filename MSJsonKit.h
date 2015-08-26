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
 * @param obj objc对象
 * @param jsonAddr  输出json字串地址
 * @param key json字串是否需要加额外的键，不加传nil
 */
+(void)objToJson: (id)obj  out: (NSMutableString **)jsonAddr withKey: (NSString *)key;

/**
 *  obj 转 json
 *
 *  @param obj obj objc对象
 *  @param key key json字串是否需要加额外的键，不加传nil
 *
 *  @return  json字符串
 */
+(NSString *)objToJson: (id)obj withKey: (NSString *)key;
/**
 * json 转 obj
 * @param json 需转化的json字符串
 * @param mclass  需转化成的objc类
 * @result (id) 转化后的objc对象
 */
+(id)jsonToObj: (NSString *)json asClass: (Class)mclass;
/**
 * json 转 obj
 * @param json 需转化的json字符串
 * @param mclass  需转化成的objc类
 * @param keyClass 如果有某个objc类属性为NSArray或者NSDictionay, 可以传入@{@"asdf"(该属性键): (数组每项的类型或者字典每个值的类型),....},否则传nil
 * 
 * @result (id) 转化后的objc对象
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
