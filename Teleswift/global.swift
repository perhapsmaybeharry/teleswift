//
//  global.swift
//  Teleswift
//
//  Created by Harry Wang on 19/8/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Foundation
import Cocoa


/// Various levels of severity that can be thrown by Teleswift.
public enum errorSeverity: String {
	case STANDARD
	case UNKNOWN
	case SERIOUS
	case FATAL
}

/// Various errors thrown from the API (HTTPInterface.swift).
public enum apiError: Error {
	case noConnection
	case connectionFailed(withReason: String)
	case notOK
	case invalidParameter(offensive: String)
	case filterError
	case unknown(error: String)
}

/// Various errors thrown from the Telegram API.
public enum tgError: Error {
	// 400
	case method_not_found // generic
	case chat_not_found // generic
	case chat_id_is_empty // generic
	case message_text_is_empty // sendMessage
	case wrong_user_id_specified // generic
	case wrong_parameter_action_in_request // sendChatAction
	case wrong_persistent_file_id // getFile
	case there_is_no_photo_in_the_request // getPhoto
	
	// 401
	case unauthorized
	
	// 404
	case not_found
	
	// Unknown
	case unknown(error: String)
}

internal func parseTgError(code: Int, desc: String) throws {
	switch code {
		case 400:
			switch desc {
				case "method not found": throw tgError.method_not_found
				case "chat not found": throw tgError.chat_not_found
				case "chat_id is empty": throw tgError.chat_id_is_empty
				case "message text is empty": throw tgError.message_text_is_empty
				case "wrong user id specified": throw tgError.wrong_user_id_specified
				case "wrong_parameter_action_in_request": throw tgError.wrong_parameter_action_in_request
				case "wrong persistent file id": throw tgError.wrong_persistent_file_id
				case "there is no photo in the request": throw tgError.there_is_no_photo_in_the_request
				
				default: throw tgError.unknown(error: desc)
			}
		case 401 where desc == "Unauthorized": throw tgError.unauthorized
		case 404: throw tgError.not_found
		default: throw tgError.unknown(error: desc)
	}
}

/// Various errors thrown from the Class Initialisers (classes.swift).
public enum classError: Error {
	case jsonNotAllValuesPresent(String)
	case jsonTooManyValuesPresent( String)
	case unknown(String)
}


internal extension String {
	/// Removes the last character of the string.
	internal mutating func removeLast() {self = self.substring(to: index(before: self.endIndex))}
}

internal extension JSON {
	internal func contains(_ key: String) -> Bool {if self[key] != nil {return true} else {return false}}
	internal func containsAllOf(_ keys: [String]) -> (String, Bool) {
		var missing = Swift.String()
		for i in keys {if !self.contains(i) {missing.append("\(i), ")}}
		if missing != Swift.String() {
			missing.removeLast()
			missing.removeLast()
			return (missing, false)
		} else {return (missing, true)}
	}
	internal func containsOnlyOneOf(_ keys: [String]) -> (String, Bool) {
		var counter: Int = 0, matches = Swift.String()
		for i in keys {if self.contains(i) {counter += 1; matches.append("\(i), ")}}
		if counter > 1 {
			matches.removeLast() // trims off extraneous comma and space from the last match
			matches.removeLast()
			return (matches, false)
		} else {return (matches, true)}
	}
}

public class Console {
	open var log: [String]
	open var outputLimit: Int
	open var textView: NSTextView?
	open var logVerbosely: Bool = true
	open var logErrors: Bool = true
	
	public init(with_outputLimit: Int = 256, with_textView: NSTextView? = nil, shouldLogVerbosely: Bool = true, shouldLogErrors: Bool = true) {
		log = [String]()
		outputLimit = with_outputLimit
		textView = with_textView
		logVerbosely = shouldLogVerbosely
		logErrors = shouldLogErrors
	}
	
	/// Function to log verbosely.
	internal func verbosity(_ message: String, caller: String = #function.components(separatedBy: "(").first!) {
		if log.count > outputLimit {log = Array(log[(log.count-(outputLimit+1))..<(log.count)])}
		log.append("[\(caller)] \(message)")
		if logVerbosely {print(log.last!); if textView != nil {DispatchQueue.main.async{self.textView?.xlog(self.log.last!)}}}
	}
	
	/// Function to log errors with variable levels of severity.
	internal func error(_ message: String, severity: errorSeverity = .STANDARD, caller: String = #function.components(separatedBy: "(").first!) {
		if log.count > outputLimit {log.removeFirst()}
		log.append("[ERROR/\(severity)] \(message)")
		if logErrors {print(log.last!); if textView != nil {DispatchQueue.main.async{self.textView?.xlog(self.log.last!)}}}
	}
	
	open func clear() {log = [String]()}
	
}

public extension NSTextView {
	public func appendText(_ line: String) {
		DispatchQueue.main.async {
			let astring = NSAttributedString(string: "\(line)\n", attributes: nil)
			self.textStorage?.append(astring)
			
			self.scrollToEndOfDocument(self)
//			let loc = self.string?.lengthOfBytes(using: String.Encoding.utf8)
			
//			let range = NSRange(location: loc!, length: 0)
//			self.scrollRangeToVisible(range)
		}
	}
	public func xlog(_ line: String) {self.appendText(line)}
}
