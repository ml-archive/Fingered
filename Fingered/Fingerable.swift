//
//  Fingerable.swift
//  Fingered
//
//  Created by Chris on 12/12/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

public protocol Fingerable {
	var fingerIdentifier: String { get }
	var fingerPassword: String { get }
	var fingerUserInfo: [String: AnyObject]? { get }
}
