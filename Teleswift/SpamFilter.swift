//
//  SpamFilter.swift
//  Teleswift
//
//  Created by Harry Wang on 19/9/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Foundation

open class SpamFilter {
	
	// Fancy-shmancy configurability.
	/// Determines if the spam filter should warn spammers. This does not affect manual warn(_:) calls.
	open var shouldWarn: Bool = true
	/// Determines if the spam filter should block spammers. This does not affect manual excommunicate(_:) calls.
	open var shouldExcom: Bool = true
	
	/// This log keeps track of the user IDs and their offences
	open var log = [(user: User, count: Int, excommunicated: Bool, excomCount: Int, reliefTime: Date)]()
	
	/// This value represents the minimum interval between messages to determine spam in seconds.
	open var interval: Int = 0
	
	/// This value represents how long an excommunicated offender will be excommunicated in minutes. This number is the base for an exponential function which determines the duration of the interval by excomDuration^excomCount (i.e. 2^2 = 4 minutes for the second offence).
	open var excomDuration: Double = 2
	
	/// This value represents the message sent to warn spamming users.
	open var warnMessage: String = "Please do not spam me!\n<em>You have been warned.</em>"
	
	/// This value represents the message sent to excommunicated users.
	open var excomMessage: String = "You have been excommunicated and your messages <strong>will be ignored.</strong>"
	
	/// This value represents the message sent to users whose excommunications have been lifted.
	open var liftedMessage: String = "Your excommunication has been lifted. <em>Please do not spam me!</em>"
	
	/// This value represents how many offences an offender must collect to receive a warning
	open var firstThreshold: Int = 4
		
	/// This value represents how many offences an offender must collect to be excommunicated
	open var secondThreshold: Int = 12
	
	/// Internal variables.
	open var token: String
	open var logVerbosely: Bool = true
	internal var console: Console
	
	/// Default value initialiser
	public init(botToken: String, shouldLogVerbosely: Bool = true, toConsole: Console) {token = botToken; logVerbosely = shouldLogVerbosely; console = toConsole}
	
	/// Specific-value initialiser
	public init(with_interval: Int, with_excomDuration: Double, with_firstThreshold: Int, with_secondThreshold: Int, botToken: String, shouldLogVerbosely: Bool = true, toConsole: Console) {
		interval = with_interval
		excomDuration = with_excomDuration
		firstThreshold = with_firstThreshold
		secondThreshold = with_secondThreshold
		token = botToken
		logVerbosely = shouldLogVerbosely
		console = toConsole
	}
	
	open func filter(_ toFilter: [Update]) throws -> [Update] {
		
		return try autoreleasepool(invoking: { () -> [Update] in
			
			var filtered = [Update](), currentSession = [User]()
			
			// Checks if toFilter has data.
			if toFilter.count == 0 {
				try checkForExcomLift()
				return toFilter
			}
			
			// Checks if user database has no data. Adds the first user.
			if log.count == 0 {log.append((user: toFilter.first!.message.from, count: 0, excommunicated: false, excomCount: 0, reliefTime: Date()))}
			
			// Add users to user database. If users are already in database, skip
			for i in toFilter {
				var doesContain = Bool()
				for j in log {
					if j.user.id == i.message.from.id {doesContain = true}
				}
				if !doesContain {
					log.append((user: i.message.from, count: 0, excommunicated: false, excomCount: 0, reliefTime: Date())); break
				}
				
				// adds users in current spam filter session to the currentSession array
				currentSession.append(i.message.from)
			}
			
			if toFilter.count == 1 {
				for i in log {
					if i.user.id == toFilter.first!.message.from.id && !i.excommunicated {
						return toFilter
					}
				}
			}
			
			// Checks if message per second rate exceeds that of the specified spam definition from the same user
			for i in 0..<toFilter.count-1 {
				if toFilter[i].message.from.id == toFilter[i+1].message.from.id && toFilter[i+1].message.date-toFilter[i].message.date <= interval {
					// messages are spam
					for j in 0..<log.count {
						// finds the user in the database and adds 1 to their count
						if log[j].user.id == toFilter[i].message.from.id && !log[j].excommunicated {log[j].count += 1; break}
					}
				} else {
					// messages aren't spam.
					
					// add messages from unexcommunicated users
					for j in 0..<log.count {
						if toFilter[i].message.from.id == log[j].user.id && !log[j].excommunicated {
							filtered.append(toFilter[i]); break
						}
					}
				}
			}
			
			// execute excommunications here
			for i in 0..<log.count {
				
				// checks if any users have exceeded the thresholds
				if log[i].count >= firstThreshold && log[i].count < secondThreshold && currentSession.contains(log[i].user) {
					// warn
					if shouldWarn {try warn(logEntry: &log[i])}
					
				} else if log[i].count >= secondThreshold && log[i].excommunicated == false && currentSession.contains(log[i].user) {
					// excommunicate!
					if shouldExcom {try excommunicate(logEntry: &log[i])}
				}
			}
			
			try checkForExcomLift()
			
			console.verbosity("unfiltered: \(toFilter.count); filtered: \(filtered.count)", caller: #function)
			return filtered
			
		})
	}
	
	/// checks if anyone's excommunications are due for lifting
	private func checkForExcomLift() throws {
		return try autoreleasepool(invoking: {
			for i in 0..<log.count {
				if log[i].excommunicated {
					if log[i].reliefTime.compare(Date()) == ComparisonResult.orderedAscending || log[i].reliefTime.compare(Date()) == ComparisonResult.orderedSame  {
						// lift excommunication
						try unexcommunicate(logEntry: &log[i])
					}
				}
			}
		})
	}
	
	/// function that excommunicates user specified in the log entry
	open func excommunicate(logEntry: inout (user: User, count: Int, excommunicated: Bool, excomCount: Int, reliefTime: Date)) throws {
		try autoreleasepool(invoking: {
			let ts = Teleswift(token)
			
			logEntry.excommunicated = true
			logEntry.excomCount += 1
			logEntry.reliefTime = Date().addingTimeInterval(TimeInterval(pow(excomDuration, Double(logEntry.excomCount))*60))
			console.verbosity("excommunicated \(logEntry.user.id) - \(logEntry.user.first_name) \(logEntry.user.last_name)", caller: #function)
			_ = try ts.sendMessage(chat_id: String(logEntry.user.id), text: "\(excomMessage)\n\nYour excommunication will last <strong>\(pow(excomDuration, Double(logEntry.excomCount))) minute(s)</strong> and be lifted on <strong>\(logEntry.reliefTime) UTC</strong>.\n\nThe time now is <strong>\(Date()) UTC</strong>.", parse_mode: "HTML")
		})
	}
	
	/// function that unexcommunicates user specified in the log entry
	open func unexcommunicate(logEntry: inout (user: User, count: Int, excommunicated: Bool, excomCount: Int, reliefTime: Date)) throws {
		try autoreleasepool(invoking: {
			let ts = Teleswift(token)
			console.verbosity("un-excommunicated \(logEntry.user.id) - \(logEntry.user.first_name) \(logEntry.user.last_name)", caller: "filter")
			_ = try ts.sendMessage(chat_id: (String(logEntry.user.id)), text: liftedMessage, parse_mode: "HTML")
			logEntry.excommunicated = false
			logEntry.count = 0
		})
	}
	
	/// function that warns user specified in the log entry
	open func warn(logEntry: inout (user: User, count: Int, excommunicated: Bool, excomCount: Int, reliefTime: Date)) throws {
		
		try autoreleasepool(invoking: {
			let ts = Teleswift(token)
			_ = try ts.sendMessage(chat_id: String(logEntry.user.id), text: warnMessage, parse_mode: "HTML")
			console.verbosity("warned \(logEntry.user.id) - \(logEntry.user.first_name) \(logEntry.user.last_name)", caller: #function)
		})
	}
	
	/// function that derives log entry from user ID
	open func getLogEntryFromID(user_id: Int) -> (Bool, Int) {
		for i in 0..<log.count {
			if log[i].user.id == user_id {return (true, i)}
		}
		return (false, Int())
	}
}
