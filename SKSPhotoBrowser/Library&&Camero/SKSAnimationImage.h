//
//  SKSAnimationImage.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/26.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, SKSLogLevel) {
    SKSLogLevelNone = 0,
    SKSLogLevelError,
    SKSLogLevelWarn,
    SKSLogLevelInfo,
    SKSLogLevelDebug,
    SKSLogLevelVerbose
};

extern const NSTimeInterval kSKSAnimationImageDelayTimeIntervalMinimum;

@interface SKSAnimationImage : NSObject

@property (nonatomic, strong, readonly) UIImage *posterImage; // Guaranteed to be loaded; usually equivalent to `-imageLazilyCachedAtIndex:0`
@property (nonatomic, assign, readonly) CGSize size; // The `.posterImage`'s `.size`

@property (nonatomic, assign, readonly) NSUInteger loopCount; // 0 means repeating the animation indefinitely
@property (nonatomic, strong, readonly) NSDictionary *delayTimesForIndexes; // Of type `NSTimeInterval` boxed in `NSNumber`s
@property (nonatomic, assign, readonly) NSUInteger frameCount; // Number of valid frames; equal to `[.delayTimes count]`

@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeCurrent; // Current size of intelligently chosen buffer window; can range in the interval [1..frameCount]
@property (nonatomic, assign) NSUInteger frameCacheSizeMax; // Allow to cap the cache size; 0 means no specific limit (default)

// Intended to be called from main thread synchronously; will return immediately.
// If the result isn't cached, will return `nil`; the caller should then pause playback, not increment frame counter and keep polling.
// After an initial loading time, depending on `frameCacheSize`, frames should be available immediately from the cache.
- (UIImage *)imageLazilyCachedAtIndex:(NSUInteger)index;

// Pass either a `UIImage` or an `SKSAnimationImage` and get back its size
+ (CGSize)sizeForImage:(id)image;

// On success, the initializers return an `SKSAnimationImage` with all fields initialized, on failure they return `nil` and an error will be logged.
- (instancetype)initWithAnimatedGIFData:(NSData *)data;
// Pass 0 for optimalFrameCacheSize to get the default, predrawing is enabled by default.
- (instancetype)initWithAnimatedGIFData:(NSData *)data optimalFrameCacheSize:(NSUInteger)optimalFrameCacheSize predrawingEnabled:(BOOL)isPredrawingEnabled NS_DESIGNATED_INITIALIZER;
+ (instancetype)animatedImageWithGIFData:(NSData *)data;

@property (nonatomic, strong, readonly) NSData *data; // The data the receiver was initialized with; read-only

@end


@interface SKSAnimationImage (Logging)

+ (void)setLogBlock:(void (^)(NSString *logString, SKSLogLevel logLevel))logBlock logLevel:(SKSLogLevel)logLevel;
+ (void)logStringFromBlock:(NSString *(^)(void))stringBlock withLevel:(SKSLogLevel)level;

@end

#define FLLog(logLevel, format, ...) [SKSAnimationImage logStringFromBlock:^NSString *{ return [NSString stringWithFormat:(format), ## __VA_ARGS__]; } withLevel:(logLevel)]

@interface SKSWeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end


