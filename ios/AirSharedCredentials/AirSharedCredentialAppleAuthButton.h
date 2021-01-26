//
//  AirSharedCredentialAppleAuthButton.h
//  AirSharedCredentials
//
//  Created by Mateo Kozomara on 18/03/2020.
//  Copyright © 2020 FreshPlanet. All rights reserved.
//

#import "FPANEUtils.h"
#include <TargetConditionals.h>
#import <AuthenticationServices/AuthenticationServices.h>
#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#else
    #import <AppKit/AppKit.h>
#endif

@interface AirSharedCredentialAppleAuthButton : NSObject<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@end

void AirSharedCredentialsAppleAuthListFunctions(const FRENamedFunction** functionsToSet, uint32_t* numFunctionsToSet, FREContext ctx);


