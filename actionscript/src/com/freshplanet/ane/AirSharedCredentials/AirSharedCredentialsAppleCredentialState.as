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
package com.freshplanet.ane.AirSharedCredentials {
public class AirSharedCredentialsAppleCredentialState {
	/***************************
	 *
	 * PUBLIC
	 *
	 ***************************/

	static public const REVOKED                  	: AirSharedCredentialsAppleCredentialType = new AirSharedCredentialsAppleCredentialType(Private, "revoked");
	static public const AUTHORIZED                    : AirSharedCredentialsAppleCredentialType = new AirSharedCredentialsAppleCredentialType(Private, "authorized");
	static public const NOT_FOUND                    : AirSharedCredentialsAppleCredentialType = new AirSharedCredentialsAppleCredentialType(Private, "not_found");
	static public const TRANSFERRED                    : AirSharedCredentialsAppleCredentialType = new AirSharedCredentialsAppleCredentialType(Private, "transferred");
	static public const UNKNOWN                    : AirSharedCredentialsAppleCredentialType = new AirSharedCredentialsAppleCredentialType(Private, "unknown");


	public static function fromValue(value:String):AirSharedCredentialsAppleCredentialType {

		switch (value)
		{
			case REVOKED.value:
				return REVOKED;
				break;
			case AUTHORIZED.value:
				return AUTHORIZED;
				break;
			case NOT_FOUND.value:
				return NOT_FOUND;
				break;
			case TRANSFERRED.value:
				return TRANSFERRED;
				break;
			case UNKNOWN.value:
				return UNKNOWN;
				break;

			default:
				return null;
				break;
		}
	}

	public function get value():String {
		return _value;
	}

	/***************************
	 *
	 * PRIVATE
	 *
	 ***************************/

	private var _value:String;

	public function AirSharedCredentialsAppleCredentialState(access:Class, value:String) {

		if (access != Private)
			throw new Error("Private constructor call!");

		_value = value;
	}
}
}
final class Private {}