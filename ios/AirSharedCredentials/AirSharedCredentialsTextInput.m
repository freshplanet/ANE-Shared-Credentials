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

#import "AirSharedCredentialsTextInput.h"
@interface AirSharedCredentialsTextInput () {
}

@property(nonatomic, assign) FREContext context;
@property(nonatomic, assign) UITextField* textField;
@property(nonatomic, assign) UITapGestureRecognizer* tapRecognizer;


@end
@implementation AirSharedCredentialsTextInput

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithContext:(FREContext)extensionContext {
    
    self = [super init];
    
    if (self) {
        self.context = extensionContext;
        
    }
    return self;
}

- (UITextContentType) stringToUITextContentType:(NSString*)raw {
    if ([raw isEqualToString:@"UITextContentTypeUsername"]) {
        return UITextContentTypeUsername;
    } else if ([raw isEqualToString:@"UITextContentTypePassword"]) {
        return UITextContentTypePassword;
    }
    return nil;
}

- (UIKeyboardType) stringToUIKeyboardType:(NSString*)raw {
    if ([raw isEqualToString:@"UIKeyboardTypeEmailAddress"]) {
        return UIKeyboardTypeEmailAddress;
    } else if ([raw isEqualToString:@"UIKeyboardTypeDefault"]) {
        return UIKeyboardTypeDefault;
    }
    return 0;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if(_textField)
        [_textField resignFirstResponder];

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

- (void)textFieldDidChange:(UITextField *)textField {
    if(textField == _textField)
        [self sendEvent:@"AirSharedCredentialsTextInputEvent_textChanged" level:textField.text];
}

# pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
     [textField resignFirstResponder];
     [self sendEvent:@"AirSharedCredentialsTextInputEvent_return"];
     return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

# pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

DEFINE_ANE_FUNCTION(textInput_create) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        CGFloat screenScale = [UIScreen mainScreen].scale;
        
        CGFloat x = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[0])) / screenScale;
        CGFloat y = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[1])) / screenScale;
        CGFloat width = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[2])) / screenScale;
        CGFloat height = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[3])) / screenScale;
        
        NSString* placeholder = AirSharedCredentials_FPANE_FREObjectToNSString((argv[4]));
        NSString* fontName = AirSharedCredentials_FPANE_FREObjectToNSString((argv[5]));
        NSInteger fontColor = AirSharedCredentials_FPANE_FREObjectToInt((argv[6]));
        NSInteger fontSize = AirSharedCredentials_FPANE_FREObjectToInt((argv[7]));
        NSString* contentType = AirSharedCredentials_FPANE_FREObjectToNSString((argv[8]));
        NSString* keyboardType = AirSharedCredentials_FPANE_FREObjectToNSString((argv[9]));
        UIImage* icon = argc > 10 ? AirSharedCredentials_FPANE_FREBitmapDataToUIImage(argv[10]) : nil;
        
        UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UIColor *textColor = UIColorFromRGB(fontColor);
        CGRect rect = CGRectMake(x, y, width, height);
        UITextField* text = [[UITextField alloc] initWithFrame:rect];
        
        if(icon) {
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(height, height, height, height)];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height / 2.5, height / 2.5)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImage:icon];
            [leftView addSubview:imageView];
            text.leftView = leftView;
            text.leftViewMode = UITextFieldViewModeAlways;
            imageView.center = CGPointMake(leftView.frame.size.width / 2, leftView.frame.size.height / 2);
        }
       
        text.textColor = textColor;
        text.backgroundColor = [UIColor whiteColor];
        
        if([[UIDevice currentDevice] systemVersion].floatValue >= 11.0) {
            text.textContentType = [controller stringToUITextContentType:contentType];
        }
        
        if ([contentType isEqualToString:@"UITextContentTypePassword"]) {
            text.secureTextEntry = true;
        }
        
        [text setFont:[UIFont fontWithName:fontName size:fontSize]];
        [text setPlaceholder:placeholder];
        
        text.keyboardType = [controller stringToUIKeyboardType:keyboardType];
        text.autocapitalizationType = UITextAutocapitalizationTypeNone;
        text.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [rootViewController.view addSubview:text];
        
        controller.tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                action:@selector(handleSingleTap:)];
        controller.tapRecognizer.delegate = controller;
        [rootViewController.view addGestureRecognizer:controller.tapRecognizer];
        
        controller.textField = text;
        
        controller.textField.delegate = controller;
        [controller.textField addTarget:controller action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to createTextField : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_assignFocus) {
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        if(controller.textField)
            [controller.textField becomeFirstResponder];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to assignFocus : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_removeFocus) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        if(controller.textField)
            [controller.textField resignFirstResponder];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to removeFocus : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_getText) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        if(controller.textField)
            return AirSharedCredentials_FPANE_NSStringToFREObject(controller.textField.text);
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to get text : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_setText) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        NSString* text = AirSharedCredentials_FPANE_FREObjectToNSString((argv[0]));
        if(controller.textField)
            controller.textField.text = text;
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to set text : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_setFrame) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        if(controller.textField){
            CGFloat screenScale = [UIScreen mainScreen].scale;
            
            CGFloat x = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[0])) / screenScale;
            CGFloat y = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[1])) / screenScale;
            CGFloat width = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[2])) / screenScale;
            CGFloat height = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[3])) / screenScale;
            
            CGRect rect = CGRectMake(x, y, width, height);
            controller.textField.frame = rect;
        }
            
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to set frame : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_destroy) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        
        [controller.textField removeTarget:controller action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        if(controller.textField) {
            [controller.textField removeFromSuperview];
            controller.textField.delegate = nil;
        }
        
        
        if(controller.tapRecognizer) {
            UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            [rootViewController.view removeGestureRecognizer:controller.tapRecognizer];
        }
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to set frame : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_show) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        if(controller.textField) {
            [controller.textField setHidden:false];
        }
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to show textField : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_hide) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    
    @try {
        if(controller.textField) {
            [controller.textField setHidden:true];
        }
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to show textField : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_getAlpha) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    @try {
        
        if(controller.textField) {
            return AirSharedCredentials_FPANE_DoubleToFREObject(controller.textField.alpha);
        }
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to get textField alpha : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(textInput_setAlpha) {
    
    AirSharedCredentialsTextInput* controller;
    FREGetContextNativeData(context, (void**)&controller);
    
    if (controller == nil)
        return AirSharedCredentials_FPANE_CreateError(@"Context does not have an textInput controller", 0);
    @try {
        CGFloat alpha = (CGFloat)AirSharedCredentials_FPANE_FREObjectToDouble((argv[0]));
        if(controller.textField) {
            controller.textField.alpha = alpha;
        }
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to set textField alpha : " stringByAppendingString:exception.reason]];
    }
    return nil;
}

# pragma mark - list functions

void AirSharedCredentialsTextInputListFunctions(const FRENamedFunction** functionsToSet, uint32_t* numFunctionsToSet, FREContext ctx) {
    
    AirSharedCredentialsTextInput* controller = [[AirSharedCredentialsTextInput alloc] initWithContext:ctx];
    FRESetContextNativeData(ctx, (void*)CFBridgingRetain(controller));
    
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(textInput_create, NULL),
        MAP_FUNCTION(textInput_assignFocus, NULL),
        MAP_FUNCTION(textInput_removeFocus, NULL),
        MAP_FUNCTION(textInput_getText, NULL),
        MAP_FUNCTION(textInput_setText, NULL),
        MAP_FUNCTION(textInput_setFrame, NULL),
        MAP_FUNCTION(textInput_destroy, NULL),
        MAP_FUNCTION(textInput_show, NULL),
        MAP_FUNCTION(textInput_hide, NULL),
        MAP_FUNCTION(textInput_getAlpha, NULL),
        MAP_FUNCTION(textInput_setAlpha, NULL)
        
    };
    
    *numFunctionsToSet = sizeof(functions) / sizeof(FRENamedFunction);
    *functionsToSet = functions;
}
