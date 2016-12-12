//
//  Hand.swift
//  Fingered
//
//  Created by Chris on 12/12/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import LocalAuthentication

public struct Hand {
	
	private static let context = LAContext()
	
	private static func ringIsOn(finger: Fingerable) -> Bool {
		return Ring.currentFingerIdentifier == finger.fingerIdentifier
	}
	
	public static func verifyRingFinger(finger: Fingerable, withReason reason: String = "", completion: @escaping (_ success: Bool, _ error: FingerError?) -> ()) {
		if !ringIsOn(finger: finger) {
			completion(false, .wrongFinger)
		}
		
		if Hand.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			Hand.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
				if success {
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
	
	public static func proposeWithRingFor(finger: Fingerable) throws -> Bool {
		if hasAsked(finger: finger) {
			throw FingerError.alreadyAsked
		}
		else if Ring.isClaimed {
			throw FingerError.ringIsTaken
		}
		else if Hand.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			return true
		}
		else {
			throw FingerError.cannotEvaluateBiometrics
		}
	}
	
	public static func placeRingOnFinger(finger: Fingerable, withReason reason: String = "", completion: @escaping (_ success: Bool, _ error: FingerError?) -> ()) {
		if Hand.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			Hand.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
				if success {
					Ring.placeOn(finger: finger)
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
	
	private static func hasAsked(finger: Fingerable) -> Bool {
		return UserDefaults.standard.bool(forKey: Hand.HasAskedKey + "_\(finger.fingerIdentifier)")
	}
}

extension Hand {
	public enum FingerError: Error {
		case wrongFinger
		case cannotEvaluateBiometrics
		case evaluationError(error: Error)
		case unknown
		case alreadyAsked
		case ringIsTaken
	}
}

extension Hand {
	static let HasAskedKey = "FingeredHasAskedKey"
}
