//
//  AirSharedCredentialAppleAuthButton.h
//  AirSharedCredentials
//
//  Created by Mateo Kozomara on 18/03/2020.
//  Copyright © 2020 FreshPlanet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPANEUtils.h"
#import <AuthenticationServices/AuthenticationServices.h>


@interface AirSharedCredentialAppleAuthButton : NSObject<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@end

void AirSharedCredentialsAppleAuthListFunctions(const FRENamedFunction** functionsToSet, uint32_t* numFunctionsToSet, FREContext ctx);


