/*
 * Copyright 2018 FreshPlanet
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

#import "AirSharedCredentials.h"
#import "AirSharedCredentialsTextInput.h"
#import "AirSharedCredentialAppleAuthButton.h"
#import "SharedWebCredentials.h"

@interface AirSharedCredentials ()
@property (nonatomic, readonly) FREContext context;
@end

@implementation AirSharedCredentials
- (instancetype)initWithContext:(FREContext)extensionContext {
    
    if ((self = [super init])) {
        
        _context = extensionContext;
    }
    
    return self;
}

- (void) sendLog:(NSString*)log {
    [self sendEvent:@"log" level:log];
}

- (void) sendEvent:(NSString*)code {
    [self sendEvent:code level:@""];
}

- (void) sendEvent:(NSString*)code level:(NSString*)level {
    FREDispatchStatusEventAsync(_context, (const uint8_t*)[code UTF8String], (const uint8_t*)[level UTF8String]);
}

@end

AirSharedCredentials* GetAirSharedCredentialsContextNativeData(FREContext context) {
    
    CFTypeRef controller;
    FREGetContextNativeData(context, (void**)&controller);
    return (__bridge AirSharedCredentials*)controller;
}

DEFINE_ANE_FUNCTION(saveAccount) {
    
    AirSharedCredentials* controller = GetAirSharedCredentialsContextNativeData(context);
    
    if (!controller)
        return AirSharedCredentials_FPANE_CreateError(@"context's AirSharedCredentials is null", 0);
    
    @try {
        
        NSString *account = AirSharedCredentials_FPANE_FREObjectToNSString(argv[0]);
        NSString *password = AirSharedCredentials_FPANE_FREObjectToNSString(argv[1]);
        NSString *fqdn = AirSharedCredentials_FPANE_FREObjectToNSString(argv[2]);
        
        [SharedWebCredentials saveAccount:fqdn account:account password:password callback:^(CFErrorRef cfError) {
            
            if(cfError) {
                NSError *error = (__bridge NSError *)cfError;
                [controller sendLog:[@"Error occured while trying to saveAccount : " stringByAppendingString:error.localizedDescription]];
            }
            else {
                [controller sendLog:@"Account saved successfully!"];
            }
        }];
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to saveAccount : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(deleteAccount) {
    
    AirSharedCredentials* controller = GetAirSharedCredentialsContextNativeData(context);
    
    if (!controller)
        return AirSharedCredentials_FPANE_CreateError(@"context's AirSharedCredentials is null", 0);
    
    @try {
        
        NSString *account = AirSharedCredentials_FPANE_FREObjectToNSString(argv[0]);
        NSString *fqdn = AirSharedCredentials_FPANE_FREObjectToNSString(argv[1]);
        
        [SharedWebCredentials deleteAccount:fqdn account:account callback:^(CFErrorRef cfError) {
            if(cfError) {
                NSError *error = (__bridge NSError *)cfError;
                [controller sendLog:[@"Error occured while trying to deleteAccount : " stringByAppendingString:error.localizedDescription]];
            }
            else {
                [controller sendLog:@"Account deleted successfully!"];
            }
        }];
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to saveAccount : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

#pragma mark - ANE setup

void AirSharedCredentialsContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    if (strcmp((char*)ctxType, "textInput") == 0) {
        AirSharedCredentialsTextInputListFunctions(functionsToSet, numFunctionsToTest, ctx);
    }
    else if (strcmp((char*)ctxType, "appleAuth") == 0) {
        AirSharedCredentialsAppleAuthListFunctions(functionsToSet, numFunctionsToTest, ctx);
    }
    else {
        AirSharedCredentials* controller = [[AirSharedCredentials alloc] initWithContext:ctx];
        FRESetContextNativeData(ctx, (void*)CFBridgingRetain(controller));
        
        static FRENamedFunction functions[] = {
            MAP_FUNCTION(saveAccount, NULL),
            MAP_FUNCTION(deleteAccount, NULL)
        };
        *numFunctionsToTest = sizeof(functions) / sizeof(FRENamedFunction);
        *functionsToSet = functions;
    }
    
    
    
}

void AirSharedCredentialsContextFinalizer(FREContext ctx) {
    CFTypeRef controller;
    FREGetContextNativeData(ctx, (void **)&controller);
    CFBridgingRelease(controller);
}

void AirSharedCredentialsInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AirSharedCredentialsContextInitializer;
    *ctxFinalizerToSet = &AirSharedCredentialsContextFinalizer;
}

void AirSharedCredentialsFinalizer(void *extData) {}
