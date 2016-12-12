//
//  Fingerable.swift
//  Fingered
//
//  Created by Chris on 12/12/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

/// Your user model should conform to this protocol so that it can be saved in the keychain.
public protocol Fingerable {
/// The identifier to use for your user (name, id, email address, however your models are uniquely identified).
	var fingerIdentifier: String { get }
		
/// Any extra data you may need to store and retreive when using TouchID in your application.
	var fingerUserInfo: [String: AnyObject]? { get }
}
