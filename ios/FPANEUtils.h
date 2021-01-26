/*
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#include "TargetConditionals.h"
#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#endif


#define DEFINE_ANE_FUNCTION(fn) FREObject fn(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }
#define ROOT_VIEW_CONTROLLER [[[UIApplication sharedApplication] keyWindow] rootViewController]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

void AirSharedCredentials_FPANE_DispatchEvent(FREContext context, NSString* eventName);
void AirSharedCredentials_FPANE_DispatchEventWithInfo(FREContext context, NSString* eventName, NSString* eventInfo);
void AirSharedCredentials_FPANE_Log(FREContext context, NSString* message);

NSString* AirSharedCredentials_FPANE_FREObjectToNSString(FREObject object);
NSArray* AirSharedCredentials_FPANE_FREObjectToNSArrayOfNSString(FREObject object);
NSDictionary* AirSharedCredentials_FPANE_FREObjectsToNSDictionaryOfNSString(FREObject keys, FREObject values);
BOOL AirSharedCredentials_FPANE_FREObjectToBool(FREObject object);
NSInteger AirSharedCredentials_FPANE_FREObjectToInt(FREObject object);
double AirSharedCredentials_FPANE_FREObjectToDouble(FREObject object);

FREObject AirSharedCredentials_FPANE_BOOLToFREObject(BOOL boolean);
FREObject AirSharedCredentials_FPANE_IntToFREObject(NSInteger i);
FREObject AirSharedCredentials_FPANE_DoubleToFREObject(double d);
FREObject AirSharedCredentials_FPANE_NSStringToFREObject(NSString* string);
FREObject AirSharedCredentials_FPANE_CreateError(NSString* error, NSInteger* id);

#if TARGET_OS_IOS
FREObject AirSharedCredentials_FPANE_UIImageToFREBitmapData(UIImage *image);
FREObject AirSharedCredentials_FPANE_UIImageToFREByteArray(UIImage *image);
UIImage* AirSharedCredentials_FPANE_FREBitmapDataToUIImage(FREObject object);
NSArray* AirSharedCredentials_FPANE_FREObjectToNSArrayOfUIImage(FREObject object);
#endif
