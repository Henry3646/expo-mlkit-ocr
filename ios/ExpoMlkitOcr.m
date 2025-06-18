#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ExpoMlkitOcr, NSObject)

RCT_EXTERN_METHOD(recognizeText:(NSString *)imageUriString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end 