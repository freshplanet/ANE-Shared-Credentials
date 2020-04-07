//
//  AirSharedCredentialAppleAuthButton.m
//  AirSharedCredentials
//
//  Created by Mateo Kozomara on 18/03/2020.
//  Copyright © 2020 FreshPlanet. All rights reserved.
//

#import "AirSharedCredentialAppleAuthButton.h"


@interface AirSharedCredentialAppleAuthButton () {
}

@property(nonatomic, assign) FREContext context;
@property(nonatomic, assign) ASAuthorizationAppleIDButton* appleButton;



@end

@implementation AirSharedCredentialAppleAuthButton

-(id)initWithContext:(FREContext)extensionContext {
    
    self = [super init];
    
    if (self) {
        self.context = extensionContext;
        
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

- (NSString*)convertToJSonString:(NSDictionary*)dict {
    
    if (!dict)
        return @"{}";
    
    NSError* jsonError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    if (jsonError != nil) {
        
        NSString *log = [@"[AirSharedCredentials] JSON stringify error: " stringByAppendingString:jsonError.localizedDescription];
        [self sendLog:log];
        return @"{}";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSDictionary*)convertASAuthorizationCredentialToDictionary:(id)credential {
    
    if(!credential)
        return nil;
    
    NSMutableDictionary *result = nil;
    if (@available(iOS 13.0, *)) {
        result = [[NSMutableDictionary alloc] init];
        
        if ([credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
            
            ASAuthorizationAppleIDCredential *appleIDCredential = credential;
            
            if(appleIDCredential.user)
                [result setValue:appleIDCredential.user forKey:@"user"];
            
            if(appleIDCredential.authorizationCode) {
                NSUInteger len = appleIDCredential.authorizationCode.length;
                const unsigned char *buffer = appleIDCredential.authorizationCode.bytes;
                NSMutableString *tokenString  = [NSMutableString stringWithCapacity:(len * 2)];
                for (int i = 0; i < len; ++i) {
                    [tokenString appendFormat:@"%02x", buffer[i]];
                }
                [result setValue:tokenString forKey:@"token"];
            }
                
            
            if(appleIDCredential.fullName && appleIDCredential.fullName.familyName)
                [result setValue:appleIDCredential.fullName.familyName forKey:@"lastName"];
            if(appleIDCredential.fullName && appleIDCredential.fullName.givenName)
                [result setValue:appleIDCredential.fullName.givenName forKey:@"name"];
            if(appleIDCredential.email)
                [result setValue:appleIDCredential.email forKey:@"email"];
            
            [result setValue:@"appleID" forKey:@"type"];
            
            
        }
        else if ([credential isKindOfClass:[ASPasswordCredential class]]) {
            
            ASPasswordCredential *passwordCredential = credential;
            if(passwordCredential.user)
                [result setValue:passwordCredential.user forKey:@"user"];
            if(passwordCredential.password)
                [result setValue:passwordCredential.password forKey:@"password"];
            
            [result setValue:@"password" forKey:@"type"];
            
        }
    }
    
    return result;
    
}


- (void)requestCredentials {

    if (@available(iOS 13.0, *)) {
        
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        ASAuthorizationAppleIDRequest *appleIDRequest = appleIDProvider.createRequest;
        appleIDRequest.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

        ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest]];

        controller.delegate = self;
        controller.presentationContextProvider = self;
        [controller performRequests];
    }
}

#pragma mark - ASAuthorizationControllerDelegate

 - (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
     return rootViewController.view.window;
    
}

#pragma mark - ASAuthorizationControllerDelegate

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization NS_SWIFT_NAME(authorizationController(controller:didCompleteWithAuthorization:))  API_AVAILABLE(ios(13.0)){
    
    NSString *credString = [self convertToJSonString:[self convertASAuthorizationCredentialToDictionary: authorization.credential]];
    
    [self sendEvent:@"AirSharedCredentialsAppleAuthEvent_success" level:credString];
    
}


- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  NS_SWIFT_NAME(authorizationController(controller:didCompleteWithError:))  API_AVAILABLE(ios(13.0)){
    NSString *errorMessage;
    if(error.code == ASAuthorizationErrorCanceled) {
        errorMessage = @"UserCanceled";
    }
    else  {
        errorMessage = error.localizedDescription;
    }
    
    [self sendEvent:@"AirSharedCredentialsAppleAuthEvent_error" level:errorMessage];
}

@end

DEFINE_ANE_FUNCTION(appleAuth_create) {
    
       AirSharedCredentialAppleAuthButton* controller;
       FREGetContextNativeData(context, (void**)&controller);
       
       if (controller == nil)
           return AirSharedCredentials_FPANE_CreateError(@"Context does not have an AppleAuthButton controller", 0);
    
    
    @try {
        if (@available(iOS 13.0, *)) {
            CGFloat screenScale = [UIScreen mainScreen].scale;
            
            CGFloat x = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[0])) / screenScale;
            CGFloat y = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[1])) / screenScale;
            CGFloat width = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[2])) / screenScale;
            CGFloat height = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[3])) / screenScale;
            
            UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            
            // Sign In With Apple Button
            ASAuthorizationAppleIDButton *appleIDButton = [ASAuthorizationAppleIDButton new];
            appleIDButton.frame =  CGRectMake(x, y, width, height);
            appleIDButton.cornerRadius = CGRectGetHeight(appleIDButton.frame) * 0.25;
            [rootViewController.view addSubview:appleIDButton];
            controller.appleButton = appleIDButton;
            
            [controller.appleButton addTarget:controller action:@selector(requestCredentials) forControlEvents:UIControlEventTouchUpInside];
        }
        else
            [controller sendEvent:@"AirSharedCredentialsAppleAuthEvent_error" level:@"Available only on iOS >= 13"];
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to createAppleAuthButton : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
    
}

DEFINE_ANE_FUNCTION(appleAuth_setFrame) {
    
    AirSharedCredentialAppleAuthButton* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an AppleAuthButton controller", 0);
    
    @try {
        if(controller.appleButton){
            CGFloat screenScale = [UIScreen mainScreen].scale;
            
            CGFloat x = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[0])) / screenScale;
            CGFloat y = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[1])) / screenScale;
            CGFloat width = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[2])) / screenScale;
            CGFloat height = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[3])) / screenScale;
            
            CGRect rect = CGRectMake(x, y, width, height);
            controller.appleButton.frame = rect;
        }
            
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to set frame : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(appleAuth_show) {
    
    AirSharedCredentialAppleAuthButton* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an AppleAuthButton controller", 0);
    
    @try {
        if(controller.appleButton){
            [controller.appleButton setHidden:false];
        }
            
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to show AppleButton : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(appleAuth_hide) {
    
    AirSharedCredentialAppleAuthButton* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an AppleAuthButton controller", 0);
    
    @try {
        if(controller.appleButton){
            [controller.appleButton setHidden:true];
        }
            
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to hide AppleButton : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(appleAuth_destroy) {
    
    AirSharedCredentialAppleAuthButton* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an AppleAuthButton controller", 0);
    
    @try {
        if(controller.appleButton) {
            [controller.appleButton removeTarget:controller action:@selector(requestCredentials) forControlEvents:UIControlEventTouchUpInside];
            [controller.appleButton removeFromSuperview];
            controller.appleButton = nil;
        }
            
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to destroy AppleButton : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(appleAuth_requestCredential) {
    
    AirSharedCredentialAppleAuthButton* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an AppleAuthButton controller", 0);
    
    @try {
        [controller requestCredentials];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to requestCredential : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(appleAuth_getCredentialState) {
    
    AirSharedCredentialAppleAuthButton* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an AppleAuthButton controller", 0);
    
    @try {
        
        NSString *userId = AirSharedCredentials_FPANE_FREObjectToNSString(argv[0]);
        
        if (@available(iOS 13.0, *)) {
            ASAuthorizationAppleIDProvider *provider = [ASAuthorizationAppleIDProvider new];
            [provider getCredentialStateForUserID:userId completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
                
                if(error) {
                    // send event about the error
                    [controller sendEvent:@"AirSharedCredentialsAppleAuthCredentialStateEvent_error" level:error.localizedDescription];
                    return;
                }
                
                NSString *state;
                if(credentialState == ASAuthorizationAppleIDProviderCredentialAuthorized) {
                    state = @"authorized";
                }
                else if(credentialState == ASAuthorizationAppleIDProviderCredentialRevoked) {
                    state = @"revoked";
                }
                else if(credentialState == ASAuthorizationAppleIDProviderCredentialNotFound) {
                    state = @"not_found";
                }
                else if(credentialState == ASAuthorizationAppleIDProviderCredentialTransferred) {
                    state = @"transferred";
                }
                else {
                    state = @"unknown";
                }
                
                [controller sendEvent:@"AirSharedCredentialsAppleAuthCredentialStateEvent_success" level:error.localizedDescription];
                
                
            }];
        } else {
            // Fallback on earlier versions
            [controller sendEvent:@"AirSharedCredentialsAppleAuthCredentialStateEvent_error" level:@"Available only on iOS >= 13"];
        }
       
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to getCredentialState : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

# pragma mark - list functions

void AirSharedCredentialsAppleAuthListFunctions(const FRENamedFunction** functionsToSet, uint32_t* numFunctionsToSet, FREContext ctx) {
    
    AirSharedCredentialAppleAuthButton* controller = [[AirSharedCredentialAppleAuthButton alloc] initWithContext:ctx];
    FRESetContextNativeData(ctx, (void*)CFBridgingRetain(controller));
    
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(appleAuth_create, NULL),
        MAP_FUNCTION(appleAuth_setFrame, NULL),
        MAP_FUNCTION(appleAuth_show, NULL),
        MAP_FUNCTION(appleAuth_hide, NULL),
        MAP_FUNCTION(appleAuth_requestCredential, NULL),
        MAP_FUNCTION(appleAuth_getCredentialState, NULL),
        MAP_FUNCTION(appleAuth_destroy, NULL)
        
    };
    
    *numFunctionsToSet = sizeof(functions) / sizeof(FRENamedFunction);
    *functionsToSet = functions;
}