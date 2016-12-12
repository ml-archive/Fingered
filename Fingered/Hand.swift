//
//  Hand.swift
//  Fingered
//
//  Created by Chris on 12/12/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import LocalAuthentication

/// The Hand is the main HANDler of the Finger and Ring.
public struct Hand {
	
	private static let context = LAContext()
	

///	Checks to see if the ring is currentlyl on the provided finger. If the ring is
///	not on any fingers, it will return false.
///
///	- parameter finger: Check to see if the ring is on this finger.
	
	private static func ringIsOn(finger: Fingerable) -> Bool {
		return Ring.currentFingerIdentifier == finger.fingerIdentifier
	}
	
	
///	Verifies the TouchID status if the finger has the ring. Call this method whenever you want to retrieve
///	the credentials to log your user in.
///
///	- parameter finger: The user to attempt to log in with.
///	- parameter reason: The message to display in the TouchID alert view.
///	- parameter completion: Called when the fingerprint scan was a success, or if an error occurs.
/// - parameter ringFinger: The full details of the stored user, nil if there was an error.
/// - parameter error: Error details if the verification was unsuccessful.
	
	public static func verifyRingFinger(finger: Fingerable, withReason reason: String = "", completion: @escaping (_ ringFinger: Ring.RingFinger?, _ error: FingerError?) -> ()) {
		if !ringIsOn(finger: finger) {
			completion(nil, .noRingOnFinger)
		}
		
		if Hand.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			Hand.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
				if success {
					completion(Ring.currentFullFinger, nil)
				}
				else if let error = error {
					completion(nil, .evaluationError(error: error))
				}
				else {
					completion(nil, .unknown)
				}
			})
		}
		else {
			completion(nil, .cannotEvaluateBiometrics)
		}
	}
	
/// Checks various conditions to ensure that the ring can be placed on a given finger.
/// If this returns true, you should display something to your user letting them know that
/// TouchID is available, and/or ask them if they would like to use it. 
/// NOTE: This method will only return true ONCE per user.
///
/// - parameter finger: The user to check validity of.
/// - throws: A `FingerError` based on the issue that prevents the ring from being placed on the given finger.
/// - returns: `true` if the ring can be placed
	
	public static func proposeWithRingFor(finger: Fingerable) throws -> Bool {
		if hasAsked(finger: finger) {
			throw FingerError.alreadyAsked
		}
		else if Ring.isClaimed {
			throw FingerError.ringIsTaken
		}
		else if Hand.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			UserDefaults.standard.set(true, forKey: Hand.HasAskedKey + "_\(finger.fingerIdentifier)")
			return true
		}
		else {
			throw FingerError.cannotEvaluateBiometrics
		}
	}
	
/// Finally stores the user data in the keychain by placing the ring on the given finger. Call this
/// method after the user has agreed to store their info in keychain for use with TouchID.
///
/// - parameter finger: The user to store in keychain.
/// - parameter password: The password to store along with the user. 
/// - parameter reason: The message to display in the TouchID alert view.
/// - parameter completion: Called with the method has completed.
/// - parameter success: True if the user was stored in the keychain.
/// - parameter error: Error details if any part of the storage failed.
	public static func placeRingOnFinger(finger: Fingerable, withVow password: String, withReason reason: String = "", completion: @escaping (_ success: Bool, _ error: FingerError?) -> ()) {
		if Hand.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			Hand.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
				if success {
					Ring.placeOn(finger: finger, withVow: password)
					completion(true, nil)
				}
				else if let error = error {
					completion(false, .evaluationError(error: error))
				}
				else {
					completion(false, .unknown)
				}
			})
		}
		else {
			completion(false, .cannotEvaluateBiometrics)
		}
	}
/// Checks to see if this user has already been asked about storing
	private static func hasAsked(finger: Fingerable) -> Bool {
		return UserDefaults.standard.bool(forKey: Hand.HasAskedKey + "_\(finger.fingerIdentifier)")
	}
}

extension Hand {
	public enum FingerError: Error {
		/// There is no ring on this finger
		case noRingOnFinger
		/// Most likely this is a device without TouchID support
		case cannotEvaluateBiometrics
		/// There was an error with the `evaluatePolicy` call, check the nested error for more info
		case evaluationError(error: Error)
		/// Something unknown occurred
		case unknown
		/// This finger has already been asked
		case alreadyAsked
		/// The ring is already on another finger
		case ringIsTaken
	}
}

extension Hand {
	static let HasAskedKey = "FingeredHasAskedKey"
}
