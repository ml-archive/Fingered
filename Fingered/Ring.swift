//
//  Ring.swift
//  Fingered
//
//  Created by Chris on 12/12/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

public struct Ring {
	
	private static let keychainWrapper = KeychainWrapper()
	
	public static var currentFingerIdentifier: String? {
		return keychainWrapper.object(forKey: IdentifierKey) as? String
	}
	
	public static var currentFullFinger: (identifier: String, password: String, userInfo: [String: AnyObject]?) {
		let id = keychainWrapper.object(forKey: IdentifierKey) as? String ?? ""
		let pass = keychainWrapper.object(forKey: PasswordKey) as? String ?? ""
		let userInfo = keychainWrapper.object(forKey: UserInfoKey) as? [String: AnyObject]
		return (id, pass, userInfo)
	}
	
	public static var isClaimed: Bool {
		return UserDefaults.standard.bool(forKey: Ring.IsClaimed) //TODO: User something better than UserDefaults?
	}
	
	public static func placeOn(finger: Fingerable) {
		keychainWrapper.setObject(finger.fingerIdentifier, forKey: Ring.IdentifierKey)
		keychainWrapper.setObject(finger.fingerPassword, forKey: Ring.PasswordKey)
		keychainWrapper.setObject(finger.fingerUserInfo, forKey: Ring.UserInfoKey)
		
		UserDefaults.standard.set(true, forKey: Ring.IsClaimed)
		keychainWrapper.writeToKeychain()
	}
}

extension Ring {
	static let IdentifierKey = "FingeredIdentifierKey"
	static let PasswordKey = "FingeredPasswordKey"
	static let UserInfoKey = "FingeredUserInfoKey"
	
	static let IsClaimed = "FingeredIsClaimedKey"
}
