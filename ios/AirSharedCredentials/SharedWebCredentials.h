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
#import <Foundation/Foundation.h>

@interface SharedWebCredentials : NSObject

+ (void) saveAccount:(NSString*)fqdn account:(NSString*)account password:(NSString*)password callback:(void(^)(CFErrorRef error))handler;
+ (void) deleteAccount:(NSString*)fqdn account:(NSString*)account callback:(void(^)(CFErrorRef error))handler;

@end
