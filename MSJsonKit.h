//
//  MSJsonKit.h
//  
//
//  Created by Minster on 14/10/20.
//  
//

#import <Foundation/Foundation.h>

@protocol MSJsonSerializing

@required
///示例  key 为属性名，value为json key 名， 不实现该协议就表示属性名和json key名一样
///+ (NSDictionary *)JSONKeyPathsByPropertyKey {
///         return @{
///             @"name": @"name_",
///             @"myPoint": @"my_point",
///             @"starred": @"starred"
///         };
///     }
+ (NSDictionary *)jsonKeyPathsByPropertyKey;

@optional
//示例：转化函数返回值必须是NSObject子类，本身属性非NSObject子类的会自动转化，如
//本身属性      返回值类型     转化后
//BOOL         NSNumber     !=0 为YES ==0 为NO
//其他数字类型   NSNumber     与NSNumber同值
//+ (NSDictionary *)jsonValueConverter {
//    return @{
//             @"time": (NSDate *)^(NSNumber *time) {
//                 return [NSDate dateWithTimeIntervalSince1970: [time doubleValue]];
//             }
//             };
//}
//

+ (NSDictionary *)jsonValueConverter;
//示例：转化函数返回值必须是NSString类型或其子类
//+ (NSDictionary *)objcValueConverter {
//    return @{
//             @"time": (NSString *)^(NSDate *time) {
//                 return [NSString stringWithFormat: @"%qi", (long long)([time timeIntervalSince1970])];
//             }
//             };
//}
+ (NSDictionary *)objcValueConverter;

+ (NSArray *)toJsonIgnoreKey;

/**
 *  指定类型为NSArray或者NSDictionary属性的子项的类型
 *
 *  @return 类型为NSArray或者NSDictionary属性的子项的类型
 */
+ (NSDictionary *)keyClass;

@end

@interface MSJsonKit : NSObject
/**
 * obj 转 json 该方法将递归调用
 * @param obj objc对象
 * @param jsonAddr  输出json字串地址
 * @param key json字串是否需要加额外的键，不加传nil
 * @param baseClass 如果是第一次递归调用，该值为obj的类型，否则为其上层对象的类型
 * @param preKey 如果是第一次递归调用，该值赋值为key一样的值，否则为其上层对象该属性的名称
 */
+(void)objToJson: (id)obj  out: (NSMutableString **)jsonAddr withKey: (NSString *)key baseClass: (Class)baseClass preKey: (NSString *)preKey;

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
/**
 * jsonObj 转 obj
 * @param json 需转化的json字符串
 * @param mclass  需转化成的objc类
 * @param keyClass 如果有某个objc类属性为NSArray或者NSDictionay, 可以传入@{@"asdf"(该属性键): (数组每项的类型或者字典每个值的类型),....},否则传nil
 *
 * @result (id) 转化后的objc对象
 */
+(id)jsonObjToObj: (id)jsonObj asClass:(Class)mclass WithKeyClass: (NSDictionary *) keyClass;
/**
 * jsonObj 转 obj
 * @param json 需转化的json字符串
 * @param mclass  需转化成的objc类
 * @param keyClass 如果有某个objc类属性为NSArray或者NSDictionay, 可以传入@{@"asdf"(该属性键): (数组每项的类型或者字典每个值的类型),....},否则传nil
 *
 * @result (id) 转化后的objc对象
 */
+(id)jsonObjToObj: (id)jsonObj asClass:(Class)mclass;

+ (void)setShouldLog: (BOOL)should_log;
@end

@interface MSJsonKit(Private)
+(id)jsonObjToObj: (id)jsonObj asClass:(Class)mclass WithKeyClass: (NSDictionary *) keyClass ForKey: (NSString *)keyName baseClass: (Class)baseClass;
+(NSString *)getStringJson: (NSString *)str withKey: (NSString *)key baseClass: (Class)baseClass preKey: (NSString *)preKey;
+(NSString *)getNumberJson: (NSNumber *)num withKey: (NSString *)key baseClass: (Class)baseClass preKey: (NSString *)preKey;
+(NSString *)getNullJsonWithKey: (NSString *)key baseClass: (Class)baseClass preKey: (NSString *)preKey;
+(NSString *)getBoolJson: (BOOL)flag withKey: (NSString *)key baseClass: (Class)baseClass preKey: (NSString *)preKey;
+(NSString *)getDateJson: (NSDate *) date withKey: (NSString *)key baseClass: (Class)baseClass preKey: (NSString *)preKey;
@end
