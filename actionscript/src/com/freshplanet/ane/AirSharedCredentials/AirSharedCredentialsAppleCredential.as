package com.freshplanet.ane.AirSharedCredentials {
	public class AirSharedCredentialsAppleCredential {

		private var _type:AirSharedCredentialsAppleCredentialType;
		private var _user:String;
		private var _password:String;
		private var _name:String;
		private var _lastName:String;
		private var _token:String;
		private var _email:String;

		public function AirSharedCredentialsAppleCredential(
				type:AirSharedCredentialsAppleCredentialType,
				user:String,
				password:String,
				name:String,
				lastName:String,
				token:String,
				email:String) {
			_type = type;
			_user = user;
			_password = password;
			_name = name;
			_lastName = lastName;
			_token = token;
			_email = email;
		}

		public function get type():AirSharedCredentialsAppleCredentialType {
			return _type;
		}

		public function get user():String {
			return _user;
		}

		public function get password():String {
			return _password;
		}

		public function get name():String {
			return _name;
		}

		public function get lastName():String {
			return _lastName;
		}

		public function get token():String {
			return _token;
		}

		public function get email():String {
			return _email;
		}
	}
}
