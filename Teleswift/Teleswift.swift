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
		didSet {http.logVerbosely = self.logVerbosely; sf.logVerbosely = self.logVerbosely}}
	open var logErrors: Bool {didSet {http.logErrors = self.logErrors}}
	fileprivate var token: String
	fileprivate var http: HTTPInterface
	open var sf: SpamFilter
	public init (_ botToken: String, shouldLogVerbosely: Bool = true, shouldLogErrors: Bool = true) {
		token = botToken
		logVerbosely = shouldLogVerbosely
		logErrors = shouldLogErrors
		http = HTTPInterface(botToken: token)
		sf = SpamFilter(botToken: token)
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
		
		return try autoreleasepool(invoking: { () -> [Update] in
			var argumentArray = [String]()
			if offset != Int() {argumentArray.append("offset=\(offset)")}
			if limit != Int() {if (limit > 0 || limit <= 100) {throw apiError.invalidParameter(offensive: "limit=\(limit)")}; argumentArray.append("limit=\(limit)")}
			if timeout != Int() {argumentArray.append("")}
			
			var arrayOfUpdates = [Update]()
			let updates = try http.call("getUpdates", arguments: argumentArray)
			for i in try updates.array() {
				arrayOfUpdates.append(try Update(i))
			}
			
//			if arrayOfUpdates.count == 0 {return arrayOfUpdates}
//			arrayOfUpdates.remove(at: 0)
			
			if shouldFilter {return try sf.filter(arrayOfUpdates)} else {return arrayOfUpdates}
		})
		
	}
	
	open func getMe() throws -> User {return try User(try http.call("getMe"))}
	
	open func sendMessage(chat_id: String, text: String, parse_mode: String = String(), disable_web_page_preview: Bool = false, disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		return try autoreleasepool(invoking: { () throws -> Message in
			
			if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
			if text == "" {throw apiError.invalidParameter(offensive: "text is blank")}
			
			var argumentArray = ["chat_id=\(chat_id)", "text=\(text)"]
			if parse_mode != String() && (parse_mode == "HTML" || parse_mode == "Markdown") {argumentArray.append("parse_mode=\(parse_mode)")}
			if disable_web_page_preview {argumentArray.append("disable_web_page_preview=\(disable_web_page_preview)")}
			if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
			
			return try Message(try http.call("sendMessage", arguments: argumentArray))
			
		})
	}
	
	open func forwardMessage(chat_id: String, from_chat_id: String, message_id: Int, disable_notification: Bool = false) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if from_chat_id == "" {throw apiError.invalidParameter(offensive: "from_chat_id is blank")}
		if message_id == Int() {throw apiError.invalidParameter(offensive: "message_id is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "from_chat_id=\(from_chat_id)", "message_id=\(message_id)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		
		return try Message(try http.call("forwardMessage", arguments: argumentArray))
	
	}
	
	open func sendPhoto(chat_id: String, photo: String, caption: String = String(), disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if photo == "" {throw apiError.invalidParameter(offensive: "photo is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "photo=\(photo)"]
		if caption != String() {argumentArray.append("caption=\(caption)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendPhoto", arguments: argumentArray))
		
	}
	
	open func sendAudio(chat_id: String, audio: Audio, disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if audio.file_id == Audio().file_id {throw apiError.invalidParameter(offensive: "audio is blank")}
	
		var argumentArray = ["chat_id=\(chat_id)", "audio=\(audio.file_id)"]
		if audio.duration != Audio().duration {argumentArray.append("duration=\(audio.duration)")}
		if audio.performer != Audio().performer {argumentArray.append("performer=\(audio.performer)")}
		if audio.title != Audio().title {argumentArray.append("title=\(audio.title)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendAudio", arguments: argumentArray))
		
	}
	
	open func sendDocument(chat_id: String, document: String, caption: String = String(), disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if document == "" {throw apiError.invalidParameter(offensive: "document is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "document=\(document)"]
		if caption != String() {argumentArray.append("caption=\(caption)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendDocument", arguments: argumentArray))
		
	}
	
	open func sendSticker(chat_id: String, sticker: String, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if sticker == "" {throw apiError.invalidParameter(offensive: "sticker is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "sticker=\(sticker)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendSticker", arguments: argumentArray))
		
	}
	
	open func sendVideo(chat_id: String, video: Video, caption: String = String(), disable_notification: Bool = false, reply_to_message_id: Int = Int()) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if video.file_id == Video().file_id {throw apiError.invalidParameter(offensive: "video is blank")}
		
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
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if voice.file_id == Voice().file_id {throw apiError.invalidParameter(offensive: "voice is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "voice=\(voice.file_id)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendVoice", arguments: argumentArray))
		
	}
	
	open func sendLocation(chat_id: String, location: Location, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if location.latitude == Location().latitude {throw apiError.invalidParameter(offensive: "location is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "latitude=\(location.latitude)", "longitude=\(location.longitude)"]
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendLocation", arguments: argumentArray))
		
	}
	
	open func sendVenue(chat_id: String, location: Location, venue: Venue, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if location.latitude == Location().latitude {throw apiError.invalidParameter(offensive: "location is blank")}
		if venue.address == Venue().address {throw apiError.invalidParameter(offensive: "venue is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "latitude=\(location.latitude)", "longitude=\(location.longitude)", "title=\(venue.title)", "address=\(venue.address)"]
		if venue.foursquare_id != Venue().foursquare_id {argumentArray.append("foursquare_id=\(venue.foursquare_id)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendVenue", arguments: argumentArray))
		
	}
	
	open func sendContact(chat_id: String, contact: Contact, disable_notification: Bool = false, reply_to_message_id: Int) throws -> Message {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if contact.user_id == Contact().user_id {throw apiError.invalidParameter(offensive: "contact is blank")}
		
		var argumentArray = ["chat_id=\(chat_id)", "phone_number=\(contact.phone_number)", "first_name=\(contact.first_name)"]
		if contact.last_name != Contact().last_name {argumentArray.append("last_name=\(contact.last_name)")}
		if disable_notification {argumentArray.append("disable_notification=\(disable_notification)")}
		if reply_to_message_id != Int() {argumentArray.append("reply_to_message_id=\(reply_to_message_id)")}
		
		return try Message(try http.call("sendContact", arguments: argumentArray))
		
	}
	
	open func sendChatAction(chat_id: String, action: String) throws {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if action == "" {throw apiError.invalidParameter(offensive: "action is blank")}
	
		if !(action == "typing" || action == "upload_photo" || action == "record_video" || action == "upload_video" || action == "record_audio" || action == "upload_audio" || action == "upload_document" || action == "find_location") {throw apiError.invalidParameter(offensive: action)}
		
		_ = try http.call("sendChatAction", arguments: ["chat_id=\(chat_id)", "action=\(action)"])
		
	}
	
	open func getUserProfilePhotos(user_id: String, offset: Int = Int(), limit: Int = Int()) throws -> UserProfilePhotos {
		
		if user_id == "" {throw apiError.invalidParameter(offensive: "user_id is blank")}
		
		var argumentArray = ["user_id=\(user_id)"]
		if offset != Int() {argumentArray.append("offset=\(offset)")}
		if limit != Int() {if limit < 1 || limit > 100 {throw apiError.invalidParameter(offensive: "limit should be between 1 and 100, limit was set to \(limit)")}; argumentArray.append("limit=\(limit)")}
		
		return try UserProfilePhotos(try http.call("getUserProfilePhotos", arguments: argumentArray))
		
	}
	
	open func getFile(file_id: String) throws -> File {
		if file_id == "" {throw apiError.invalidParameter(offensive: "file_id is blank")}
		return try File(try http.call("getFile", arguments: ["file_id=\(file_id)"]))
	}
	
	open func kickChatMember(chat_id: String, user_id: Int) throws -> Bool {
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if user_id == Int() {throw apiError.invalidParameter(offensive: "user_id is blank")}
		if try !validateBotAdmin(in_chat_id: chat_id) {throw apiError.invalidParameter(offensive: "Bot is not admin")}
		
		return try http.call("kickChatMember", arguments: ["chat_id=\(chat_id)", "user_id=\(user_id)"]).bool()
	}
	
	open func leaveChat(chat_id: String) throws -> Bool {
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		return try http.call("leaveChat", arguments: ["chat_id=\(chat_id)"]).bool()
	}
	
	open func unbanChatMember(chat_id: String, user_id: Int) throws -> Bool {
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		if user_id == Int() {throw apiError.invalidParameter(offensive: "user_id is blank")}
		if try !validateBotAdmin(in_chat_id: chat_id) {throw apiError.invalidParameter(offensive: "Bot is not admin")}
		
		return try http.call("unbanChatMember", arguments: ["chat_id=\(chat_id)", "user_id=\(user_id)"]).bool()
	}
	
	open func getChat(chat_id: Int) throws -> Chat {
		if chat_id == Int() {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		return try Chat(try http.call("getChat", arguments: ["chat_id=\(chat_id)"])["result"]!)
	}
	
	open func getChatAdministrators(chat_id: String) throws -> [ChatMember] {
		
		if chat_id == "" {throw apiError.invalidParameter(offensive: "chat_id is blank")}
		
		var arrayOfAdministrators = [ChatMember]()
		for i in try http.call("getChatAdministrators", arguments: ["chat_id=\(chat_id)"]).array() {arrayOfAdministrators.append(try ChatMember(i))}
		return arrayOfAdministrators
		
	}
	
	open func getChatMembersCount(chat_id: String) throws -> Int {return try http.call("getChatMembersCount", arguments: ["chat_id=\(chat_id)"]).int()}
	
	open func getChatMember(chat_id: String, user_id: Int) throws -> ChatMember {return try ChatMember(try http.call("getChatMember", arguments: ["chat_id=\(chat_id)", "user_id=\(user_id)"]))}
	
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
	
	open func clearUpdates(_ last_id: Int) throws {
		return try autoreleasepool(invoking: { () in
			let previousLogStatus = logVerbosely
			logVerbosely = false
			_=try getUpdates(offset: last_id+1)
			logVerbosely = previousLogStatus
			verbosity("cleared updates", enabled: logVerbosely, caller: #function.components(separatedBy: "(").first!)
		})
	}
	
	open func getAndClearUpdates(shouldFilter: Bool = true) throws -> [Update] {
		return try autoreleasepool(invoking: { () -> [Update] in
			let toReturn = try self.getUpdates(shouldFilter: false)
			if toReturn.count != 0 {try self.clearUpdates(toReturn.last!.update_id)}
			return shouldFilter ? try sf.filter(toReturn) : toReturn
		})
	}
	
	open func validateBotAdmin(in_chat_id: String) throws -> Bool {
		return try self.getChatMember(chat_id: in_chat_id, user_id: try self.getMe().id).status == "administrator" ? true : false
	}
}
