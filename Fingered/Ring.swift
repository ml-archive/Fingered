//
//  Ring.swift
//  Fingered
//
//  Created by Chris on 12/12/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation


/// The ring is the metaphor that represents the stored user info. The ring
/// can only be placed on one finger, and that finger will be the one that
/// is stored.

public struct Ring {
	
	private static let keychainWrapper = KeychainWrapper()
	
/// The stored finger information contained in a tuple
	public typealias RingFinger = (identifier: String, password: String, userInfo: [String: AnyObject]?)
	
/// Identifier of the currently stored Finger. Nil if none exist.
	internal static var currentFingerIdentifier: String? {
		return keychainWrapper.object(forKey: IdentifierKey) as? String
	}
	

///	Full details of the currently stored Finger. Does not return optional data, so `currentFingerIdentifier`
///	should be checked first to ensure a finger exists.
	
	internal static var currentFullFinger: RingFinger {
		let id = keychainWrapper.object(forKey: IdentifierKey) as? String ?? ""
		let pass = keychainWrapper.object(forKey: PasswordKey) as? String ?? ""
		let userInfo = keychainWrapper.object(forKey: UserInfoKey) as? [String: AnyObject]
		return (id, pass, userInfo)
	}
	
	/// True if the ring is already claimed by a finger.
	internal static var isClaimed: Bool {
		return UserDefaults.standard.bool(forKey: Ring.IsClaimed) //TODO: User something better than UserDefaults?
	}
	
	
///	Places the ring on a new finger. Old details will be overwritten, if they exist.
///
///	- parameter finger: The finger to place the ring on.

	internal static func placeOn(finger: Fingerable, withVow password: String) {
		keychainWrapper.setObject(finger.fingerIdentifier, forKey: Ring.IdentifierKey)
		keychainWrapper.setObject(password, forKey: Ring.PasswordKey)
		keychainWrapper.setObject(finger.fingerUserInfo, forKey: Ring.UserInfoKey)
		
		UserDefaults.standard.set(true, forKey: Ring.IsClaimed)
		keychainWrapper.writeToKeychain()
	}
}

/// Constants used as Keychain/UserDefaults keys
extension Ring {
	internal static let IdentifierKey = "FingeredIdentifierKey"
	internal static let PasswordKey = "FingeredPasswordKey"
	internal static let UserInfoKey = "FingeredUserInfoKey"
	
	internal static let IsClaimed = "FingeredIsClaimedKey"
}
