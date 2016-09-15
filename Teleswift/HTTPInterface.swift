//
//  HTTPInterface.swift
//  Teleswift
//
//  Created by Harry Wang on 4/8/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Foundation

internal class HTTPInterface {
	// the contents of this class are private and are used for interfacing the Framework with the HTTP API.
	// tg's http api can be queried through HTTP GET/POST requests in the following format:
	// https://api.telegram.org/bot[token]/[method name]
	
	/*
	
	  key variables
		var token: String
	
	  key functions
		synthesiseURL(tgMethod: String, arguments: [String]() = [String]())
		call(tgMethod: String, arguments: [String]() = [String]())
	
		init(botToken: String)
	
	*/
	
	// create the separate queue for command processing (may be deprecated)
//	internal let apiQueue = DispatchQueue(label: "commandProcessing", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem)

	// init and token variable + verbosity/error logging variables
	internal var token: String, logVerbosely = Bool(true), logErrors = Bool(true)
	internal init (botToken: String) {token = botToken}
	
	// synthesiseURL to synthesise proper URL for contact with TG HTTP API
	internal func synthesiseURL(_ tgMethod: String, arguments: [String] = [String](), caller: String) -> URL {
		var url: String = String("https://api.telegram.org/bot\(token)/\(tgMethod)?")
		for i in arguments {url.append("\(i)&")}
		let returnURL = String(url.characters.dropLast()).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		verbosity(returnURL, enabled: logVerbosely, caller: "synthesiseURL for \(caller.components(separatedBy: "(").first!)")
		return URL(string: returnURL)!
	}
	
	// places a call to the Telegram servers.
	internal func call(_ tgMethod: String, arguments: [String] = [String](), caller: String = #function) throws -> JSON {
		
		if Reachability()?.currentReachabilityStatus == .notReachable {error("No Internet connection", enabled: logErrors, severity: .FATAL); throw apiError.noConnection}
		
		var receivedData = Data()
		do{receivedData = try Data(contentsOf: self.synthesiseURL(tgMethod, arguments: arguments, caller: caller))} catch let err {if err.localizedDescription.contains("couldn’t be opened.") {error("Telegram API returned not OK", enabled: logErrors, severity: .FATAL); throw apiError.notOK}}
		
		let returnedData = try JSON(data: receivedData)
		
		verbosity("received: \(returnedData)", enabled: logVerbosely, caller: "call for \(caller.components(separatedBy: "(").first!)")
		return returnedData["result"]!
	}
}
