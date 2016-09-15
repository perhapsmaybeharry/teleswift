//
//  Teleswift.swift
//  Teleswift
//
//  Created by Harry Wang on 19/8/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Foundation

open class Teleswift {
	
	open var logVerbosely: Bool {
		didSet {http.logVerbosely = self.logVerbosely}}
	open var logErrors: Bool {didSet {http.logErrors = self.logErrors}}
	fileprivate var token: String
	fileprivate var http: HTTPInterface
	fileprivate let sf: SpamFilter
	public init (_ botToken: String, shouldLogVerbosely: Bool = true, shouldLogErrors: Bool = true) {
		http = HTTPInterface(botToken: botToken)
		logVerbosely = shouldLogVerbosely
		logErrors = shouldLogErrors
		token = botToken
		sf = SpamFilter(with_consideredSpam: 2, with_timeInterval: 0.5, with_threshold: 32, with_token: token)
	}
	
	// the contents of this class are public and are used for interfacing the Framework with the Swift app.
	
	/*
	
	list of TG methods:
	getUpdates -> [Updates]
	getMe -> User
	sendMessage -> Message
	forwardMessage -> Message
	sendPhoto -> Message
	sendAudio -> Message
	sendDocument -> Message
	sendSticker -> Message
	sendVideo -> Message
	sendVoice -> Message
	sendLocation -> Message
	sendVenue -> Message
	sendContact -> Message
	sendChatAction -> ()
	getUserProfilePhotos -> UserProfilePhotos
	getFile -> File
//	kickChatMember -> Bool
	leaveChat -> Bool
//	unbanChatMember -> Bool
	getChat -> Chat
	getChatAdministrators -> [ChatMember]
	getChatMembersCount -> Int
	getChatMember -> ChatMember
//	answerCallbackQuery -> Bool
	
	list of Teleswift-implemented methods:
	getFileLink
	getAndClearUpdates
	deriveNewMessages
	discernCommand
	ping
	version
	
	*/
	
	open func getUpdates(offset: Int = Int(), limit: Int = Int(), timeout: Int = Int(), shouldFilter: Bool = true) throws -> [Update] {
		
		var argumentArray = [String]()
		if offset != Int() {argumentArray.append("offset=\(offset)")}
		if limit != Int() {if (limit > 0 || limit < 100) {throw apiError.invalidParameter(offensive: "limit=\(limit)")}; argumentArray.append("limit=\(limit)")}
		if timeout != Int() {argumentArray.append("")}
		
		var arrayOfUpdates = [Update]()
		let updates = try http.call("getUpdates", arguments: argumentArray)
		for i in try updates.array() {
			arrayOfUpdates.append(try Update(i))
		}
		if shouldFilter {return try sf.filter(arrayOfUpdates)} else {return arrayOfUpdates}
		
	}
	
	open func getMe() throws -> User {return try User(try http.call("getMe"))}
	
	open func sendMessage(chat_id: String, text: String, parse_mode: String = String(), disable_web_page_preview: Bool = false, disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "text=\(text)"]
		if parse_mode != String() && (parse_mode == "HTML" || parse_mode == "Markdown") {argumentArray.append("parse_mode=\(parse_mode)")}
		if disable_web_page_preview {argumentArray.append("disable_web_page_preview=\(disable_web_page_preview)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		
		return try Message(try http.call("sendMessage", arguments: argumentArray))
		
	}
	
	open func forwardMessage(chat_id: String, from_chat_id: String, message_id: Int, disable_notification: Bool = false) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "from_chat_id=\(from_chat_id)", "message_id=\(message_id)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		
		return try Message(try http.call("forwardMessage", arguments: argumentArray))
	
	}
	
	open func sendPhoto(chat_id: String, photo: String, caption: String = String(), disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "photo=\(photo)"]
		if caption != String() {argumentArray.append("caption=\(caption)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendPhoto", arguments: argumentArray))
		
	}
	
	open func sendAudio(chat_id: String, audio: Audio, disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
	
		var argumentArray = ["chat_id=\(chat_id)", "audio=\(audio.file_id)"]
		if audio.duration != Audio().duration {argumentArray.append("duration=\(audio.duration)")}
		if audio.performer != Audio().performer {argumentArray.append("performer=\(audio.performer)")}
		if audio.title != Audio().title {argumentArray.append("title=\(audio.title)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendAudio", arguments: argumentArray))
		
	}
	
	open func sendDocument(chat_id: String, document: String, caption: String = String(), disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "document=\(document)"]
		if caption != String() {argumentArray.append("caption=\(caption)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendDocument", arguments: argumentArray))
		
	}
	
	open func sendSticker(chat_id: String, sticker: String, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "sticker=\(sticker)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendSticker", arguments: argumentArray))
		
	}
	
	open func sendVideo(chat_id: String, video: Video, caption: String = String(), disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "video=\(video.file_id)"]
		if video.width != Video().width {argumentArray.append("width=\(video.width)")}
		if video.height != Video().height {argumentArray.append("height=\(video.height)")}
		if video.duration != Video().duration {argumentArray.append("duration=\(video.duration)")}
		if caption != String() {argumentArray.append("caption=\(caption)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendVideo", arguments: argumentArray))
		
	}
	
	open func sendVoice(chat_id: String, voice: Voice, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "voice=\(voice.file_id)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendVoice", arguments: argumentArray))
		
	}
	
	open func sendLocation(chat_id: String, location: Location, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "latitude=\(location.latitude)", "longitude=\(location.longitude)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendLocation", arguments: argumentArray))
		
	}
	
	open func sendVenue(chat_id: String, location: Location, venue: Venue, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "latitude=\(location.latitude)", "longitude=\(location.longitude)", "title=\(venue.title)", "address=\(venue.address)"]
		if venue.foursquare_id != Venue().foursquare_id {argumentArray.append("foursquare_id=\(venue.foursquare_id)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendVenue", arguments: argumentArray))
		
	}
	
	open func sendContact(chat_id: String, contact: Contact, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		var argumentArray = ["chat_id=\(chat_id)", "phone_number=\(contact.phone_number)", "first_name=\(contact.first_name)"]
		if contact.last_name != Contact().last_name {argumentArray.append("last_name=\(contact.last_name)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendContact", arguments: argumentArray))
		
	}
	
	open func sendChatAction(chat_id: String, action: String) throws {
	
		if !(action == "typing" || action == "upload_photo" || action == "record_video" || action == "upload_video" || action == "record_audio" || action == "upload_audio" || action == "upload_document" || action == "find_location") {throw apiError.invalidParameter(offensive: action)}
		
		_ = try http.call("sendChatAction", arguments: ["chat_id=\(chat_id)", "action=\(action)"])
		
	}
	
	open func getUserProfilePhotos(user_id: String, offset: Int = Int(), limit: Int = Int()) throws -> UserProfilePhotos {
		
		var argumentArray = ["user_id=\(user_id)"]
		if offset != Int() {argumentArray.append("offset=\(offset)")}
		if limit != Int() {if limit < 1 || limit > 100 {throw apiError.invalidParameter(offensive: "limit should be between 1 and 100, limit was set to \(limit)")}; argumentArray.append("limit=\(limit)")}
		
		return try UserProfilePhotos(try http.call("getUserProfilePhotos", arguments: argumentArray))
		
	}
	
	open func getFile(file_id: String) throws -> File {return try File(try http.call("getFile", arguments: ["file_id=\(file_id)"]))}
	
	open func leaveChat(chat_id: String) throws -> Bool {return try http.call("leaveChat", arguments: ["chat_id=\(chat_id)"]).bool()}
	
	open func getChat(id: Int) throws -> Chat {return try Chat(try http.call("getChat", arguments: ["chat_id=\(id)"])["result"]!)}
	
	open func getChatAdministrators(chat_id: String) throws -> [ChatMember] {
		
		var arrayOfAdministrators = [ChatMember]()
		for i in try http.call("getChatAdministrators", arguments: ["chat_id=\(chat_id)"]).array() {arrayOfAdministrators.append(try ChatMember(i))}
		return arrayOfAdministrators
		
	}
	
	open func getChatMembersCount(chat_id: String) throws -> Int {return try http.call("getChatMembersCount", arguments: ["chat_id=\(chat_id)"]).int()}
	
	open func getChatMember(chat_id: String, user_id: Int) throws -> ChatMember {return try ChatMember(try http.call("getChatMember", arguments: ["chat_id=\(chat_id)", "user_id=\(user_id)"]))}
	
	
	// Test function for generic purposes
//	open func test() throws -> JSON {return try http.call("getUpdates")}
	
	// Teleswift Implemented
	open func getFileLink(file_id: String) throws -> URL {return URL(string: "https://api.telegram.org/file/bot\(http.token)/\(try getFile(file_id: file_id).file_path)")!}
	
	open func ping() throws -> Double {
		let startTime = Date()
		_ = try getMe()
		let endTime = Date()
		
		return Double((endTime.timeIntervalSince(startTime) as Double)*100)
	}
	
	open func discernCommands(updates: [Update]) -> [(command: String, fromMessage: Message)] {
		var arrayOfCommands = [(command: String, fromMessage: Message)]()
		for i in updates {
			for j in i.message.entities {
				if j.type == "bot_command" {
					arrayOfCommands.append((command: i.message.text, fromMessage: i.message))
				}
			}
		}
		return arrayOfCommands
	}
	
	open func clearUpdates() throws {
		let previousLogStatus = logVerbosely
		logVerbosely = false
		if try getUpdates(shouldFilter: false).last?.update_id == nil {logVerbosely = previousLogStatus; return}
		_=try getUpdates(offset: getUpdates(shouldFilter: false).last!.update_id+1)
		logVerbosely = previousLogStatus
		verbosity("[\(#function.components(separatedBy: "(").first!)] cleared updates", enabled: logVerbosely)
	}
}

open class SpamFilter {
	
	var shouldWarnUserAtFirstThreshold: Bool = false
//	var shouldTempBlockUserAtSecondThreshold: Bool = false
	
	/// Defines the first threshold to warn users who spam this number of messages in the defined time interval.
	var threshold: Int = 32
	/// Defines the second threshold to warn users who spam this number of messages in the defined time interval after they have violated the first threshold.
//	var secondThreshold: Int = 64
	
	/// Defines the warning message that the filter sends to the user who spams.
	var warnMessage: String = "Please do not spam me! You have been warned."
	/// Defines the temporary block duration in minutes.
//	var tempBlockDuration: Int = 2880  // quantity in minutes
	/// Cooldown for block in minutes.
	var cooldown = 1440
	
	/// Defines if the spam filter should warn/block users whose spam has been isolated in the filter.
	var shouldActOnFilterResults: Bool = true
	
	/// Defines the number of messages that determine spam. If this number of messages is exceeded within the time interval by a single user, spam is logged.
	var consideredSpam: Double = 1
	/// Defines the spam filter's time interval in seconds. If within this time interval the number of messages is exceeded by a single user, spam is logged.
	var timeInterval: Double = 0.1
	
	/// Token to use for Teleswift session.
	var token: String
	
	init(with_consideredSpam: Double, with_timeInterval: Double, with_threshold: Int, with_token: String) {
		consideredSpam = with_consideredSpam
		timeInterval = with_timeInterval
		threshold = with_threshold
		token = with_token
	}
	
	/// Keeps track of the offences each user makes across calls to filter().
	private var offenceLog = [(user: User, offenceCount: Int)]()
	
	func filter(_ toFilter: [Update]) throws -> [Update] {
		
		if toFilter.count == 0 || toFilter.count == 1 {return toFilter}
		
		for i in toFilter {
			
			var doesContain = Bool()
			for j in offenceLog {
				if i.message.from.id == j.user.id {doesContain = true; break}
				doesContain = false
			}
			
			if !doesContain {
				offenceLog.append((user: i.message.from, offenceCount: 0))
			}
		}
		
		for i in 0..<toFilter.count-1 {
			
			let startMessage = toFilter[i].message
			let currentMessage = toFilter[i+1].message
			
			if Double(currentMessage.date-startMessage.date) < (timeInterval/consideredSpam) && currentMessage.from.id == startMessage.from.id {
				for i in 0...self.offenceLog.count-1 {
					if offenceLog[i].user.id == currentMessage.from.id {
						offenceLog[i].offenceCount += 1
					}
				}
			}
		}
		
		var filtered = [Update]()
		for i in offenceLog {
			if i.offenceCount > 0 {
				
				for j in 0..<offenceLog.count {
					if i.user.id == offenceLog[j].user.id {
						offenceLog[j].offenceCount += 1
					}
					try performAntiSpamActions(user: offenceLog[j].user, offenceCount: offenceLog[j].offenceCount)
					print("\(offenceLog[j].user.first_name) has racked up \(offenceLog[j].offenceCount) offences")
				}
				
				for j in toFilter {if j.message.from.id != i.user.id {filtered.append(j); break}}
			}
		}
		return filtered
	}
	
	private func performAntiSpamActions(user: User, offenceCount: Int) throws {
		if !shouldActOnFilterResults {return}
		
		if offenceCount > threshold {
			do {_ = try Teleswift(self.token).sendMessage(chat_id: String(user.id), text: warnMessage)} catch {throw apiError.filterError}
		} else {return}
	}
}
