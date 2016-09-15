//
//  main.swift
//  teleswift-test-bot
//
//  Created by Harry Wang on 4/8/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Foundation
import Cocoa

let token = "259125766:AAFWZ-TjmagknZaqqcAWpBCKnISQuZ3YDfk", ts = Teleswift(token)


// -160927133 : Where-Wolf Patrol?
// 54233832   : Harry Wang
// 147815030  : ezra

var wherewolfpatrol = String(-160927133)
var harry = String(54233832)
var ezra = String(147815030)
var teleswift_test_group = String(-179788245)



do {
	
//	ts.logVerbosely = false
	
//	let userTestClass = try ts.getMe()
//	print(userTestClass.first_name)
//	print(userTestClass.id)
//	print(userTestClass.last_name)
//	print(userTestClass.username)
//	_=try ts.sendMessage(chat_id: "54233832", text: "Hello World")
//	let chatTestClass = try ts.getChat(id: 54233832)
//	print(chatTestClass.id)
//	print(chatTestClass.type)
//	print(chatTestClass.title)
//	print(chatTestClass.first_name)
//	print(chatTestClass.last_name)
//	print(chatTestClass.username)
	
//	let testClass = try ts.getUpdates()
//	print(testClass.first!.message.from.id)
	
//	let administrators = try ts.getChatAdministrators(chat_id: wherewolfpatrol)
	
//	try ts.sendChatAction(chat_id: harry, action: "record_video")
	
//	let newUpdates = try ts.getUpdates()
//	print(newUpdates.first!.message)
	
//	_ = try ts.sendMessage(chat_id: wherewolfpatrol, text: "ping: \(try ts.ping()) ms")
	
	while true {
		let updates = try ts.getUpdates()
		try ts.clearUpdates()
		
		
//		let updates = try ts.getUpdates(), discernedCommands = ts.discernCommands(updates: updates)
//		for i in discernedCommands {
//			print(i.fromMessage.from.first_name + " " + i.fromMessage.from.last_name + ": " + i.command)
//			_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: i.fromMessage.from.first_name + " " + i.fromMessage.from.last_name + ": " + i.command)
//			if i.command == discernedCommands.last!.command && i.fromMessage.message_id == discernedCommands.last!.fromMessage.message_id {try ts.clearUpdates()}
//		}
	}
	
}
catch apiError.notOK {print("Invalid Request")}
catch apiError.noConnection {print("No Internet connection detected")}
catch classError.jsonNotAllValuesPresent(let err) {print("Not all required values are present. Missing: \(err)")}
catch apiError.unknown(let err) {print(err)}
catch classError.unknown(let err) {print(err)}
catch apiError.invalidParameter(let err) {print(err)}
catch {print(error.localizedDescription)}
