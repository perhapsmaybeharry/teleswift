//
//  classes.swift
//  Teleswift
//
//  Created by Harry Wang on 21/8/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Foundation

/// This object represents an incoming update. Only one of the optional parameters can be present in any given update.
open class Update {
	/// The update‘s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order.
	var update_id: Int
	/// Optional. New incoming message of any kind — text, photo, sticker, etc.
	var message: Message
	/// Optional. New version of a message that is known to the bot and was edited
	var edited_message: Message
	/// Optional. New incoming inline query
//	var inline_query: InlineQuery // NYI: Inline Queries are yet to be implemented.
	/// Optional. The result of an inline query that was chosen by a user and sent to their chat partner.
//	var chosen_inline_result: ChosenInlineResult // NYI: Inline Queries are yet to be implemented.
	/// Optional. New incoming callback query
//	var callback_query: CallbackQuery
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["update_id"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		let otherContainsCheck = fromJSON.containsOnlyOneOf(["message", "edited_message", "inline_query", "chosen_inline_result", "callback_query"])
		if !otherContainsCheck.1 {throw classError.jsonTooManyValuesPresent(otherContainsCheck.0)}
		
		update_id = try fromJSON.int("update_id")
		message = fromJSON.contains("message") ? try Message(fromJSON["message"]!) : Message()
		edited_message = fromJSON.contains("edited_message") ? try Message(fromJSON["edited_message"]!) : Message()
//		callback_query = fromJSON.contains("callback_query") ? try CallbackQuery(fromJSON["callback_query"]!) : CallbackQuery()
		
	}
	
	init() {
		update_id = Int()
		message = Message()
		edited_message = Message()
//		callback_query = CallbackQuery()
	}
	
	init(with_update_id: Int, with_message: Message = Message(), with_edited_message: Message = Message()) {
		update_id = with_update_id
		message = with_message
		edited_message = with_edited_message
//		callback_query = with_callback_query
	}
	
}

/// This object represents a Telegram user or bot.
open class User {
	/// Unique identifier for this user or bot
	var id: Int
	/// User's or bot's first name
	var first_name: String
	/// Optional. User's or bot's last name
	var last_name: String
	/// Optional. User's or bot's username
	var username: String
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["id", "first_name"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		id = try fromJSON.int("id")
		first_name = try fromJSON.string("first_name")
		last_name = fromJSON.contains("last_name") ? try fromJSON.string("last_name") : String()
		username = fromJSON.contains("username") ? try fromJSON.string("username") : String()
		
	}
	
	init() {
		id = Int()
		first_name = String()
		last_name = String()
		username = String()
	}
	
	init(with_id: Int, with_first_name: String, with_last_name: String = String(), with_username: String = String()) {
		id = with_id
		first_name = with_first_name
		last_name = with_last_name
		username = with_username
	}
}

/// This object represents a chat.
open class Chat {
	/// Unique identifier for this chat. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
	var id: String
	/// Type of chat, can be either “private”, “group”, “supergroup” or “channel”
	var type: String
	/// Optional. Title, for channels and group chats
	var title: String
	/// Optional. Username, for private chats, supergroups and channels if available
	var username: String
	/// Optional. First name of the other party in a private chat
	var first_name: String
	/// Optional. Last name of the other party in a private chat
	var last_name: String
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["id", "type"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		id = try fromJSON.string("id")
		type = try fromJSON.string("type")
		title = fromJSON.contains("title") ? try fromJSON.string("title") : String()
		username = fromJSON.contains("username") ? try fromJSON.string("username") : String()
		first_name = fromJSON.contains("first_name") ? try fromJSON.string("first_name") : String()
		last_name = fromJSON.contains("last_name") ? try fromJSON.string("last_name") : String()
		
	}
	
	init() {
		id = String()
		type = String()
		title = String()
		username = String()
		first_name = String()
		last_name = String()
	}
	
	init(with_id: String, with_type: String, with_title: String = String(), with_username: String = String(), with_first_name: String = String(), with_last_name: String = String()) {
		id = with_id
		type = with_type
		title = with_title
		username = with_username
		first_name = with_first_name
		last_name = with_last_name
	}
}

/// This object represents a message.
open class Message {
	/// Unique message identifier
	var message_id: Int
	/// Optional. Sender, can be empty for messages sent to channels
	var from: User
	/// Date the message was sent in Unix time
	var date: Int
	/// Conversation the message belongs to
	var chat: Chat
	/// Optional. For forwarded messages, sender of the original message
	var forward_from: User
	/// Optional. For messages forwarded from a channel, information about the original channel
	var forward_from_chat: Chat
	/// Optional. For forwarded messages, date the original message was sent in Unix time
	var forward_date: Int
	/// Optional. For replies, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
	var reply_to_message: Message?
	/// Optional. Date the message was last edited in Unix time
	var edit_date: Int
	/// Optional. For text messages, the actual UTF-8 text of the message, 0-4096 characters.
	var text: String
	/// Optional. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text
	var entities: [MessageEntity]
	/// Optional. Message is an audio file, information about the file
	var audio: Audio
	/// Optional. Message is a general file, information about the file
	var document: Document
	/// Optional. Message is a photo, available sizes of the photo
	var photo: [PhotoSize]
	/// Optional. Message is a sticker, information about the sticker
	var sticker: Sticker
	/// Optional. Message is a video, information about the video
	var video: Video
	/// Optional. Message is a voice message, information about the file
	var voice: Voice
	/// Optional. Caption for the document, photo or video, 0-200 characters
	var caption: String
	/// Optional. Message is a shared contact, information about the contact
	var contact: Contact
	/// Optional. Message is a shared location, information about the location
	var location: Location
	/// Optional, message is a venue, information about the venue
	var venue: Venue
	/// Optional. A new member was added to the group, information about them (this member may be the bot itself)
	var new_chat_member: User
	/// Optional. A member was removed from the group, information about them (this member may be the bot itself)
	var left_chat_member: User
	/// Optional. A chat title was changed to this value
	var new_chat_title: String
	/// Optional. A chat photo was changed to this value
	var new_chat_photo: [PhotoSize]
	/// Optional. Service message: the chat photo was deleted
	var delete_chat_photo: Bool
	/// Optional. Service message: the group has been created
	var group_chat_created: Bool
	/// Optional. Service message: the supergroup has been created. This field can't be received in a message coming through updates, because bots can't be a member of a supergroup when it is created. It can only be found in reply_to_message if someone replies to the very first message in a directly created supergroup.
	var supergroup_chat_created: Bool
	/// Optional. Service message: the channel has been created. This field can't be received in a message coming through updates, because bots can't be a member of a channel when it is created. It can only be found in reply_to_message if someone replies to the very first message in a channel.
	var channel_chat_created: Bool
	/// Optional. The group has been migrated to a supergroup with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
	var migrate_to_chat_id: Int
	/// Optional. The supergroup has been migrated from a group with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
	var migrate_from_chat_id: Int
	/// Optional. Specified message was pinned. Note that the Message object in this field will not contain further reply_to_message fields even if it is itself a reply.
	var pinned_message: Message?
	
	
	convenience init(_ fromJSON: JSON) throws {
		
		self.init()
		
		let containsCheck = fromJSON.containsAllOf(["message_id", "date", "chat"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
 		message_id = try fromJSON.int("message_id")
		from = fromJSON.contains("from") ? try User(fromJSON["from"]!) : User()
		date = try fromJSON.int("date")
		chat = try Chat(fromJSON["chat"]!)
		forward_from = fromJSON.contains("forward_from") ? try User(fromJSON["forward_from"]!) : User()
		forward_from_chat = fromJSON.contains("forward_from_chat") ? try Chat(fromJSON["forward_from_chat"]!) : Chat()
		forward_date = fromJSON.contains("forward_date") ? try fromJSON.int("forward_date") : Int()
		if fromJSON.contains("reply_to_message") {reply_to_message = try Message(fromJSON["reply_to_message"]!)}
		edit_date = fromJSON.contains("edit_date") ? try fromJSON.int("edit_date") : Int()
		text = fromJSON.contains("text") ? try fromJSON.string("text") : String()
		if fromJSON.contains("entities") {
			var entityArray = [MessageEntity]()
			for i in try fromJSON.array("entities") {entityArray.append(try MessageEntity(i))}
			entities = entityArray
		} else {entities = [MessageEntity]()}
		audio = fromJSON.contains("audio") ? try Audio(fromJSON["audio"]!) : Audio()
		document = fromJSON.contains("document") ? try Document(fromJSON["document"]!) : Document()
		if fromJSON.contains("photo") {
			var photoArray = [PhotoSize]()
			for i in try fromJSON.array("photo") {photoArray.append(try PhotoSize(i))}
			photo = photoArray
		} else {photo = [PhotoSize]()}
		sticker = fromJSON.contains("sticker") ? try Sticker(fromJSON["sticker"]!) : Sticker()
		video = fromJSON.contains("video") ? try Video(fromJSON["video"]!) : Video()
		voice = fromJSON.contains("voice") ? try Voice(fromJSON["voice"]!) : Voice()
		caption = fromJSON.contains("caption") ? try fromJSON.string("caption") : String()
		contact = fromJSON.contains("contact") ? try Contact(fromJSON["contact"]!) : Contact()
		location = fromJSON.contains("location") ? try Location(fromJSON["location"]!) : Location()
		venue = fromJSON.contains("venue") ? try Venue(fromJSON["venue"]!) : Venue()
		new_chat_member = fromJSON.contains("new_chat_member") ? try User(fromJSON["new_chat_member"]!) : User()
		left_chat_member = fromJSON.contains("left_chat_member") ? try User(fromJSON["left_chat_member"]!) : User()
		new_chat_title = fromJSON.contains("new_chat_title") ? String(describing: fromJSON["new_chat_title"]) : String()
		if fromJSON.contains("new_chat_photo") {
			var photoArray = [PhotoSize]()
			for i in try fromJSON.array("new_chat_photo") {photoArray.append(try PhotoSize(i))}
			new_chat_photo = photoArray
		} else {new_chat_photo = [PhotoSize]()}
		delete_chat_photo = fromJSON.contains("delete_chat_photo") ? try fromJSON.bool("delete_chat_photo") : Bool(false)
		group_chat_created = fromJSON.contains("group_chat_created") ? try fromJSON.bool("group_chat_created") : Bool(false)
		supergroup_chat_created = fromJSON.contains("supergroup_chat_created") ? try fromJSON.bool("supergroup_chat_created") : Bool(false)
		channel_chat_created = fromJSON.contains("channel_chat_created") ? try fromJSON.bool("channel_chat_created") : Bool(false)
		migrate_to_chat_id = fromJSON.contains("migrate_to_chat_id") ? try fromJSON.int("migrate_to_chat_id") : Int()
		migrate_from_chat_id = fromJSON.contains("migrate_from_chat_id") ? try fromJSON.int("migrate_from_chat_id") : Int()
		if fromJSON.contains("pinned_message") {pinned_message = try Message(fromJSON["pinned_message"]!)}
		
	}
	
	init() {
		
		message_id = Int()
		from = User()
		date = Int()
		chat = Chat()
		forward_from = User()
		forward_from_chat = Chat()
		forward_date = Int()
//		reply_to_message = Message()
		edit_date = Int()
		text = String()
		entities = [MessageEntity]()
		audio = Audio()
		document = Document()
		photo = [PhotoSize]()
		sticker = Sticker()
		video = Video()
		voice = Voice()
		caption = String()
		contact = Contact()
		location = Location()
		venue = Venue()
		new_chat_member = User()
		left_chat_member = User()
		new_chat_title = String()
		new_chat_photo = [PhotoSize]()
		delete_chat_photo = Bool()
		group_chat_created = Bool()
		supergroup_chat_created = Bool()
		channel_chat_created = Bool()
		migrate_to_chat_id = Int()
		migrate_from_chat_id = Int()
//		pinned_message = Message()
		
	}
	
	init(with_message_id: Int, with_from: User = User(), with_date: Int, with_chat: Chat, with_forward_from: User = User(), with_forward_from_chat: Chat = Chat(), with_forward_date: Int = Int(), with_reply_to_message: Message = Message(), with_edit_date: Int = Int(), with_text: String = String(), with_entities: [MessageEntity] = [MessageEntity](), with_audio: Audio = Audio(), with_document: Document = Document(), with_photo: [PhotoSize] = [PhotoSize](), with_sticker: Sticker = Sticker(), with_video: Video = Video(), with_voice: Voice = Voice(), with_caption: String = String(), with_contact: Contact = Contact(), with_location: Location = Location(), with_venue: Venue = Venue(), with_new_chat_member: User = User(), with_left_chat_member: User = User(), with_new_chat_title: String = String(), with_new_chat_photo: [PhotoSize] = [PhotoSize](), with_delete_chat_photo: Bool = Bool(), with_group_chat_created: Bool = Bool(), with_supergroup_chat_created: Bool = Bool(), with_channel_chat_created: Bool = Bool(), with_migrate_to_chat_id: Int = Int(), with_migrate_from_chat_id: Int = Int(), with_pinned_message: Message = Message()) {
		
		message_id = with_message_id
		from = with_from
		date = with_date
		chat = with_chat
		forward_from = with_forward_from
		forward_from_chat = with_forward_from_chat
		forward_date = with_forward_date
		reply_to_message = with_reply_to_message
		edit_date = with_edit_date
		text = with_text
		entities = with_entities
		audio = with_audio
		document = with_document
		photo = with_photo
		sticker = with_sticker
		video = with_video
		voice = with_voice
		caption = with_caption
		contact = with_contact
		location = with_location
		venue = with_venue
		new_chat_member = with_new_chat_member
		left_chat_member = with_left_chat_member
		new_chat_title = with_new_chat_title
		new_chat_photo = with_new_chat_photo
		delete_chat_photo = with_delete_chat_photo
		group_chat_created = with_group_chat_created
		supergroup_chat_created = with_supergroup_chat_created
		channel_chat_created = with_channel_chat_created
		migrate_to_chat_id = with_migrate_to_chat_id
		migrate_from_chat_id = with_migrate_from_chat_id
		pinned_message = with_pinned_message
		
	}
	
}

///This object represents one special entity in a text message. For example, hashtags, usernames, URLs, etc.
open class MessageEntity {
	/// Type of the entity. Can be mention (@username), hashtag, bot_command, url, email, bold (bold text), italic (italic text), code (monowidth string), pre (monowidth block), text_link (for clickable text URLs), text_mention (for users without usernames)
	var type: String
	/// Offset in UTF-16 code units to the start of the entity
	var offset: Int
	/// Length of the entity in UTF-16 code units
	var length: Int
	/// Optional. For “text_link” only, url that will be opened after user taps on the text
	var url: String
	/// Optional. For “text_mention” only, the mentioned user
	var user: User
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["type", "offset", "length"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		type = try fromJSON.string("type")
		offset = try fromJSON.int("offset")
		length = try fromJSON.int("length")
		url = fromJSON.contains("url") ? try fromJSON.string("url") : String()
		user = fromJSON.contains("user") ? try User(fromJSON["user"]!) : User()
		
	}
	
	init() {
		type = String()
		offset = Int()
		length = Int()
		url = String()
		user = User()
	}
	
	init(with_type: String, with_offset: Int, with_length: Int, with_url: String = String(), with_user: User = User()) {
		
		type = with_type
		offset = with_offset
		length = with_length
		url = with_url
		user = with_user
		
	}
}

/// This object represents one size of a photo or a file/sticker thumbnail.
open class PhotoSize {
	/// Unique identifier for this file
	var file_id: String
	/// Photo width
	var width: Int
	/// Photo height
	var height: Int
	/// Optional. File size
	var file_size: Int
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["file_id", "width", "height"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		file_id = try fromJSON.string("file_id")
		width = try fromJSON.int("width")
		height = try fromJSON.int("height")
		file_size = try fromJSON.int("file_size")
		
	}
	
	init() {
		file_id = String()
		width = Int()
		height = Int()
		file_size = Int()
	}
	
	init(with_file_id: String, with_width: Int, with_height: Int, with_file_size: Int = Int()) {
		file_id = with_file_id
		width = with_width
		height = with_height
		file_size = with_file_size
	}
}

/// This object represents an audio file to be treated as music by the Telegram clients.
open class Audio {
	/// Unique identifier for this file
	var file_id: String
	/// Duration of the audio in seconds as defined by sender
	var duration: Int
	/// Optional. Performer of the audio as defined by sender or by audio tags
	var performer: String
	/// Optional. Title of the audio as defined by sender or by audio tags
	var title: String
	/// Optional. MIME type of the file as defined by sender
	var mime_type: String
	/// Optional. File size
	
	
	var file_size: Int
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["file_id", "duration"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		file_id = try fromJSON.string("file_id")
		duration = try fromJSON.int("duration")
		performer = fromJSON.contains("performer") ? try fromJSON.string("performer") : String()
		title = fromJSON.contains("title") ? try fromJSON.string("title") : String()
		mime_type = fromJSON.contains("mime_type") ? try fromJSON.string("mime_type") : String()
		file_size = fromJSON.contains("file_size") ? try fromJSON.int("file_size") : Int()
		
	}
	
	init() {
		file_id = String()
		duration = Int()
		performer = String()
		title = String()
		mime_type = String()
		file_size = Int()
	}
	
	init(with_file_id: String, with_duration: Int, with_performer: String = String(), with_title: String = String(), with_mime_type: String = String(), with_file_size: Int = Int()) {
		file_id = with_file_id
		duration = with_duration
		performer = with_performer
		title = with_title
		mime_type = with_mime_type
		file_size = with_file_size
	}
}

/// This object represents a general file (as opposed to photos, voice messages and audio files).
open class Document {
	/// Unique file identifier
	var file_id: String
	/// Optional. Document thumbnail as defined by sender
	var thumb: PhotoSize
	/// Optional. Original filename as defined by sender
	var file_name: String
	/// Optional. MIME type of the file as defined by sender
	var mime_type: String
	/// Optional. File size
	var file_size: Int
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["file_id"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		file_id = try fromJSON.string("file_id")
		thumb = fromJSON.contains("thumb") ? try PhotoSize(fromJSON["thumb"]!) : PhotoSize()
		file_name = fromJSON.contains("file_name") ? try fromJSON.string("file_name") : String()
		mime_type = fromJSON.contains("mime_type") ? try fromJSON.string("mime_type") : String()
		file_size = fromJSON.contains("file_size") ? try fromJSON.int("file_size") : Int()
		
	}
	
	init() {
		file_id = String()
		thumb = PhotoSize()
		file_name = String()
		mime_type = String()
		file_size = Int()
	}
	
	init(with_file_id: String, with_thumb: PhotoSize = PhotoSize(), with_file_name: String = String(), with_mime_type: String = String(), with_file_size: Int = Int()) {
		file_id = with_file_id
		thumb = with_thumb
		file_name = with_file_name
		mime_type = with_mime_type
		file_size = with_file_size
	}
}

/// This object represents a sticker.
open class Sticker {
	/// Unique identifier for this file
	var file_id: String
	/// Sticker width
	var width: Int
	/// Sticker height
	var height: Int
	/// Optional. Sticker thumbnail in .webp or .jpg format
	var thumb: PhotoSize
	/// Optional. Emoji associated with the sticker
	var emoji: String
	/// Optional. File size
	var file_size: Int

	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["file_id", "width", "height"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		file_id = try fromJSON.string("file_id")
		width = try fromJSON.int("width")
		height = try fromJSON.int("height")
		thumb = fromJSON.contains("thumb") ? try PhotoSize(fromJSON["thumb"]!) : PhotoSize()
		emoji = fromJSON.contains("emoji") ? try fromJSON.string("emoji") : String()
		file_size = fromJSON.contains("file_size") ? try fromJSON.int("file_size") : Int()
		
	}
	
	init() {
		file_id = String()
		width = Int()
		height = Int()
		thumb = PhotoSize()
		emoji = String()
		file_size = Int()
	}
	
	init(with_file_id: String, with_width: Int, with_height: Int, with_thumb: PhotoSize = PhotoSize(), with_emoji: String = String(), with_file_size: Int = Int()) {
		file_id = with_file_id
		width = with_width
		height = with_height
		thumb = with_thumb
		emoji = with_emoji
		file_size = with_file_size
	}
}

/// This object represents a video file.
open class Video {
	/// Unique identifier for this file
	var file_id: String
	/// Video width as defined by sender
	var width: Int
	/// video height as defined by sender
	var height: Int
	/// Duration of the video in seconds as defined by sender
	var duration: Int
	/// Optional. Video thumbnail
	var thumb: PhotoSize
	/// Optional. MIME type of the file as defined by sender
	var mime_type: String
	/// Optional. File size
	var file_size: Int

	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["file_id", "width", "height", "duration"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		file_id = try fromJSON.string("file_id")
		width = try fromJSON.int("width")
		height = try fromJSON.int("height")
		duration = try fromJSON.int("duration")
		thumb = fromJSON.contains("thumb") ? try PhotoSize(fromJSON["thumb"]!) : PhotoSize()
		mime_type = fromJSON.contains("mime_type") ? try fromJSON.string("mime_type") : String()
		file_size = fromJSON.contains("file_size") ? try fromJSON.int("file_size") : Int()
		
	}
	
	init() {
		file_id = String()
		width = Int()
		height = Int()
		duration = Int()
		thumb = PhotoSize()
		mime_type = String()
		file_size = Int()
	}
	
	init(with_file_id: String, with_width: Int, with_height: Int, with_duration: Int, with_thumb: PhotoSize = PhotoSize(), with_mime_type: String = String(), with_file_size: Int = Int()) {
		file_id = with_file_id
		width = with_width
		height = with_height
		duration = with_duration
		thumb = with_thumb
		mime_type = with_mime_type
		file_size = with_file_size
	}
}

/// This object represents a voice note.
open class Voice {
	/// Unique identifier for this file
	var file_id: String
	/// Duration of the audio in seconds as defined by sender
	var duration: Int
	/// Optional. MIME type of the file as defined by sender
	var mime_type: String
	/// Optional. File size
	var file_size: Int

	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["file_id", "duration"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		file_id = try fromJSON.string("file_id")
		duration = try fromJSON.int("duration")
		mime_type = fromJSON.contains("mime_type") ? try fromJSON.string("mime_type") : String()
		file_size = fromJSON.contains("file_size") ? try fromJSON.int("file_size") : Int()
		
	}
	
	init() {
		file_id = String()
		duration = Int()
		mime_type = String()
		file_size = Int()
	}
	
	init(with_file_id: String, with_duration: Int, with_mime_type: String = String(), with_file_size: Int = Int()) {
		file_id = with_file_id
		duration = with_duration
		mime_type = with_mime_type
		file_size = with_file_size
	}
}

/// This object represents a phone contact.
open class Contact {
	/// Contact's phone number
	var phone_number: String
	/// Contact's first name
	var first_name: String
	/// Optional. Contact's last name
	var last_name: String
	/// Optional. Contact's user identifier in Telegram
	var user_id: Int

	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["phone_number", "first_name"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		phone_number = try fromJSON.string("phone_number")
		first_name = try fromJSON.string("first_name")
		last_name = fromJSON.contains("last_name") ? try fromJSON.string("last_name") : String()
		user_id = fromJSON.contains("user_id") ? try fromJSON.int("user_id") : Int()
		
	}
	
	init() {
		phone_number = String()
		first_name = String()
		last_name = String()
		user_id = Int()
	}
	
	init(with_phone_number: String, with_first_name: String, with_last_name: String = String(), with_user_id: Int = Int()) {
		phone_number = with_phone_number
		first_name = with_first_name
		last_name = with_last_name
		user_id = with_user_id
	}
}

/// This object represents a point on the map
open class Location {
	/// Longitude as defined by sender
	var longitude: Float
	/// Latitude as defined by sender
	var latitude: Float

	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["longtitude", "latitude"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		longitude = Float(exactly: try fromJSON.double("longitude"))!
		latitude = Float(exactly: try fromJSON.double("latitude"))!
		
	}
	
	init() {
		longitude = Float()
		latitude = Float()
	}
	
	init(with_longitude: Float, with_latitude: Float) {
		longitude = with_longitude
		latitude = with_latitude
	}
}

/// This object represents a venue.
open class Venue {
	/// Venue location
	var location: Location
	/// Name of the venue
	var title: String
	/// Address of the venue
	var address: String
	/// Optional. Foursquare identifier of the venue
	var foursquare_id: String
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["location", "title", "address"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		location = try Location(fromJSON["location"]!)
		title = try fromJSON.string("title")
		address = try fromJSON.string("address")
		foursquare_id = fromJSON.contains("foursquare_id") ? try fromJSON.string("foursquare_id") : String()
		
	}
	
	init() {
		location = Location()
		title = String()
		address = String()
		foursquare_id = String()
	}
	
	init(with_location: Location, with_title: String, with_address: String, with_foursquare_id: String = String()) {
		location = with_location
		title = with_title
		address = with_address
		foursquare_id = with_foursquare_id
	}
}

/// This object represents a user's profile pictures.
open class UserProfilePhotos {
	/// Total number of profile pictures the target user has
	var total_count: Int
	/// Requested profile pictures (in up to 4 sizes each)
	var photos: [[PhotoSize]]
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["total_count", "photos"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		total_count = try fromJSON.int("total_count")
		var arrayOfArrayOfPhotos = [[PhotoSize]]()
		for i in try fromJSON.array("photos") {
			var arrayOfPhotos = [PhotoSize]()
			for j in try i.array() {arrayOfPhotos.append(try PhotoSize(j))}
			arrayOfArrayOfPhotos.append(arrayOfPhotos)
		}
		photos = arrayOfArrayOfPhotos
		
	}
	
	init() {
		total_count = Int()
		photos = [[PhotoSize]]()
	}
	
	init(with_total_count: Int, with_photos: [[PhotoSize]]) {
		total_count = with_total_count
		photos = with_photos
	}
}

/// This object represents a file ready to be downloaded. The file can be downloaded via the link https://api.telegram.org/file/bot<token>/<file_path>. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile.
open class File {
	/// Unique identifier for this file
	var file_id: String
	/// Optional. File size, if known
	var file_size: Int
	/// Optional. File path. Use https://api.telegram.org/file/bot<token>/<file_path> to get the file
	var file_path: String
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["file_id"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		file_id = try fromJSON.string("file_id")
		file_size = fromJSON.contains("file_size") ? try fromJSON.int("file_size") : Int()
		file_path = fromJSON.contains("file_path") ? try fromJSON.string("file_path") : String()
		
	}
	
	init() {
		file_id = String()
		file_size = Int()
		file_path = String()
	}
	
	init(with_file_id: String, with_file_size: Int = Int(), with_file_path: String = String()) {
		file_id = with_file_id
		file_size = with_file_size
		file_path = with_file_path
	}
}

///// This object represents a custom keyboard with reply options (see Introduction to bots for details and examples).
//open class ReplyKeyboardMarkup {
//	/// Array of button rows, each represented by an array of KeyboardButton objects.
//	var keyboard: [[KeyboardButton]]
//	/// Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to false, in which case the custom keyboard is always of the same height as the app's standard keyboard.
//	var resize_keyboard: Bool
//	/// Optional. Requests clients to hide the keyboard as soon as it's been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat – the user can press a special button in the input field to see the custom keyboard again. Defaults to false.
//	var one_time_keyboard: Bool
//	/// Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot's message is a reply (has reply_to_message_id), sender of the original message.
//	var selective: Bool
//	
//	init(_ fromJSON: JSON) throws {
//		
//	}
//	
//	init() {
//		
//	}
//}
//
///// This object represents one button of the reply keyboard. For simple text buttons String can be used instead of this object to specify text of the button. Optional fields are mutually exclusive.
//open class KeyboardButton {
//	/// Text of the button. If none of the optional fields are used, it will be sent to the bot as a message when the button is pressed
//	var text: String
//	/// Optional. If True, the user's phone number will be sent as a contact when the button is pressed. Available in private chats only
//	var request_contact: Bool
//	/// Optional. If True, the user's current location will be sent when the button is pressed. Available in private chats only
//	var request_location: Bool
//	
//	init(_ fromJSON: JSON) throws {
//		
//	}
//	
//	init() {
//		
//	}
//}
//
///// Upon receiving a message with this object, Telegram clients will hide the current custom keyboard and display the default letter-keyboard. By default, custom keyboards are displayed until a new keyboard is sent by a bot. An exception is made for one-time keyboards that are hidden immediately after the user presses a button (see ReplyKeyboardMarkup).
//open class ReplyKeyboardHide {
//	/// Requests clients to hide the custom keyboard
//	var hide_keyboard: Bool
//	/// Optional. Use this parameter if you want to hide keyboard for specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot's message is a reply (has reply_to_message_id), sender of the original message
//	var selective: Bool
//
//	init(_ fromJSON: JSON) throws {
//		
//	}
//	
//	init() {
//		
//	}
//}
//
///// This object represents an inline keyboard that appears right next to the message it belongs to.
//open class InlineKeyboardMarkup {
//	/// Array of button rows, each represented by an Array of InlineKeyboardButton objects
//	var inline_keyboard: [[InlineKeyboardButton]]
//	
//	init(_ fromJSON: JSON) throws {
//		
//	}
//	
//	init() {
//		
//	}
//}
//
///// This object represents one button of an inline keyboard. You must use exactly one of the optional fields.
//open class InlineKeyboardButton {
//	/// Label text on the button
//	var text: String
//	/// Optional. HTTP URL to be opened when button is pressed.
//	var url: String
//	/// Optional. Data to be sent in a callback query to the bot when button is pressed, 1-64 bytes
//	var callback_data: String
//	/// Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot‘s username and the specified inline query in the input field. Can be empty, in which case just the bot’s username will be inserted.
//	var switch_inline_query: String
//
//	init(_ fromJSON: JSON) throws {
//		
//	}
//	
//	init() {
//		
//	}
//}
//
///// This object represents an incoming callback query from a callback button in an inline keyboard. If the button that originated the query was attached to a message sent by the bot, the field message will be presented. If the button was attached to a message sent via the bot (in inline mode), the field inline_message_id will be presented.
//open class CallbackQuery {
//	/// Unique identifier for this query
//	var id: String
//	/// Sender
//	var from: User
//	/// Optional. Message with the callback button that originated the query. Note that the message content and message date will not be available if the message is too old
//	var message: Message
//	/// Optional. Identifier of the message sent via the bot in inline mode, that originated the query
//	var inline_message_id: String
//	/// Data associated with the calback button. Be aware that a bad client can send arbitrary data in this field
//	var data: String
//	
//	init(_ fromJSON: JSON) throws {
//		
//	}
//	
//	init() {
//		
//	}
//}
//
///// Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot‘s message and tapped ’Reply'). This can be extremely useful if you want to create user-friendly step-by-step interfaces without having to sacrifice privacy mode.
//open class ForceReply {
//	/// Shows reply interface to the user, as if they manually selected the bot‘s message and tapped ’Reply'
//	var force_reply: Bool
//	/// Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot's message is a reply (has reply_to_message_id), sender of the original message.
//	var selective: Bool
//	
//	init(_ fromJSON: JSON) throws {
//		
//	}
//	
//	init() {
//		
//	}
//}

/// This object contains information about one member of the chat.
open class ChatMember {
	/// Information about the user
	var user: User
	/// The member's status in the chat. Can be “creator”, “administrator”, “member”, “left” or “kicked”
	var status: String
	
	init(_ fromJSON: JSON) throws {
		
		let containsCheck = fromJSON.containsAllOf(["user", "status"])
		if !containsCheck.1 {throw classError.jsonNotAllValuesPresent(containsCheck.0)}
		
		user = try User(fromJSON["user"]!)
		status = try fromJSON.string("status")
		
	}
	
	init() {
		user = User()
		status = String()
	}
	
	init(with_user: User, with_status: String) {
		user = with_user
		status = with_status
	}
}

// TO-DO: ADD INLINE CLASSES (28 total)
