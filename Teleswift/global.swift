//
//  global.swift
//  Teleswift
//
//  Created by Harry Wang on 19/8/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Foundation

func verbosity(_ message: String, enabled: Bool, caller: String = #function.components(separatedBy: "(").first!) {if enabled {print("[\(caller)] \(message)")}}

enum errorSeverity: String {case STANDARD; case UNKNOWN; case SERIOUS; case FATAL}
func error(_ message: String, enabled: Bool, severity: errorSeverity = .STANDARD, caller: String = #function.components(separatedBy: "(").first!) {if enabled {print("[ERROR/\(severity)] \(message)")}}

/// Various errors thrown from the API (HTTPInterface.swift).
public enum apiError: Error {
	case noConnection
	case notOK
	case invalidParameter(offensive: String)
	case filterError
	case unauthorized
	case unknown(error: String)
}

/// Various errors thrown from the Class Initialisers (classes.swift).
enum classError: Error {
	case jsonNotAllValuesPresent(String)
	case jsonTooManyValuesPresent( String)
	case unknown(String)
}


extension String {
	/// Checks if the given string contains all of the elements of the given array, and returns the missing.
	func containsAllOf(set: [String]) -> (String, Bool) {
		var missing = String()
		for i in set {if !self.contains(i) {missing.append("\(i), ")}}
		if missing == String() {return (String(), true)}
		else {missing.removeLast(); missing.removeLast(); return (missing, false)}
	}
	
	/// Checks if the given string matches at least one element of the given array.
	func containsEitherOf(set: [String]) -> (String, Bool) {
		for i in set {if self.contains(i) {return (i, true)}}
		return (String(), false)
	}
	
	/// Checks if the given string matches only one of the elements of the given array.
	func containsOnlyOneOf(set: [String]) -> (String, Bool) {
		var counter: Int = 0, matches = String()
		for i in set {if self.contains(i) {counter += 1; matches.append("\(i), ")}}
		if counter > 1 {
			matches.removeLast() // trims off extraneous comma and space from the last match
			matches.removeLast()
			return (matches, false)
		} else {return (matches, true)}
	}
	
	/// Removes the last character of the string.
	mutating func removeLast() {self = self.substring(to: index(before: self.endIndex))}
	
	/// Adds the provided string to the front of the string.
	mutating func prepend(_ contentsOf: String) {self = contentsOf.appending(self)}
}

extension JSON {
	func contains(_ key: String) -> Bool {if self[key] != nil {return true} else {return false}}
	func containsAllOf(_ keys: [String]) -> (String, Bool) {
		var missing = Swift.String()
		for i in keys {if !self.contains(i) {missing.append("\(i), ")}}
		if missing != Swift.String() {
			missing.removeLast()
			missing.removeLast()
			return (missing, false)
		} else {return (missing, true)}
	}
	func containsOnlyOneOf(_ keys: [String]) -> (String, Bool) {
		var counter: Int = 0, matches = Swift.String()
		for i in keys {if self.contains(i) {counter += 1; matches.append("\(i), ")}}
		if counter > 1 {
			matches.removeLast() // trims off extraneous comma and space from the last match
			matches.removeLast()
			return (matches, false)
		} else {return (matches, true)}
	}
}
