//
//  ViewController.swift
//  teleswift-test-gui
//
//  Created by Harry Wang on 26/9/16.
//  Copyright © 2016 thisbetterwork. All rights reserved.
//

import Cocoa
import Teleswift

var preferredFont = NSFont()

class ViewController: NSViewController {
	
	var bot: Bot?
	var updateFreq = UInt32()
	
	override func viewDidLoad() {
		preferredFont = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: 0)
		NotificationCenter.default.addObserver(self, selector: #selector(discernValidityOfFields), name: NSNotification.Name.NSControlTextDidChange, object: tokenField)
		NotificationCenter.default.addObserver(self, selector: #selector(updateUpdateFrequency), name: NSNotification.Name.NSControlTextDidChange, object: updateFrequency)
		discernValidityOfFields()
	}
	func discernValidityOfFields() {
		if bot != nil && (bot?.isRunning)! {return}
		if Reachability()?.currentReachabilityStatus == .notReachable {statusField.stringValue = "Internet unreachable"; self.startBot.isEnabled = false; return}
		if tokenField.stringValue == "" {startBot.isEnabled = false; statusField.stringValue = "No bot token"; return}
		statusField.stringValue = "Verifying bot token"
		DispatchQueue(label: "verificator").async {
			var toEnable = Bool(false)
			do {_ = try Teleswift(self.tokenField.stringValue, shouldLogVerbosely: false, shouldLogErrors: false).getMe(); toEnable = true} catch {toEnable = false}
			DispatchQueue.main.async {self.startBot.isEnabled = toEnable; self.statusField.stringValue = toEnable ? "Ready" : "Invalid bot token"}
		}
	}
	func updateUpdateFrequency() {updateFreq = UInt32(updateFrequency.integerValue)}
	
	@IBOutlet var tokenField: NSTextField!
	@IBOutlet var logField: NSTextView!
	@IBOutlet var statusField: NSTextField!
	
	@IBOutlet var logVerbosely: NSButton!
	@IBOutlet var logErrors: NSButton!
	@IBOutlet var filterSpam: NSButton!
	
	@IBAction func logVerboselyWasClicked(_ sender: AnyObject) {
		if bot != nil && (bot?.isRunning)! {bot?.ts.console.logVerbosely = self.logVerbosely.state == NSOnState ? true : false}
	}
	@IBAction func logErrorsWasClicked(_ sender: AnyObject) {
		if bot != nil && (bot?.isRunning)! {bot?.ts.console.logErrors = self.logErrors.state == NSOnState ? true : false}
	}
	@IBAction func filterWasClicked(_ sender: AnyObject) {
		if bot != nil && (bot?.isRunning)! {bot?.shouldFilterSpam = self.filterSpam.state == NSOnState ? true : false}
	}
	
	
	@IBOutlet var updateFrequency: NSTextField!
	
	@IBOutlet var stopBot: NSButton!
	@IBOutlet var startBot: NSButton!
	
	@IBAction func stopBotWasClicked(_ sender: AnyObject) {
		statusField.stringValue = "Bot stopped"
		stopBot.isEnabled = false
		startBot.isEnabled = true
		tokenField.isEnabled = true
		updateFrequency.isEnabled = true
		bot?.stop = true
	}
	@IBAction func startBotWasClicked(_ sender: AnyObject) {
		
		stopBot.isEnabled = true
		startBot.isEnabled = false
		tokenField.isEnabled = false
		updateFrequency.isEnabled = false
		
		bot = Bot(token: tokenField.stringValue, toTextView: logField, shouldLogVerbosely: logVerbosely.state == NSOnState ? true : false, shouldLogErrors: logErrors.state == NSOnState ? true : false)
		bot?.updateFrequency = updateFreq
		statusField.stringValue = "Bot running"
		DispatchQueue(label: "BotQueue", qos: DispatchQoS.userInteractive).async {self.bot!.run()}
	}
	@IBAction func clearLogs(_ sender: AnyObject) {logField.textStorage?.mutableString.setString("")}
	
}

class Bot {
	
	var logView: NSTextView
	var ts: Teleswift
	var shouldFilterSpam: Bool = true {
		didSet {
			ts.console.verbosity("toggled spam filter state to \(shouldFilterSpam)", caller: "botprocess")
		}
	}
	
	var stop = false
	var isRunning = false
	var updateFrequency = UInt32(0)
	
	init(token: String, toTextView: NSTextView, shouldLogVerbosely: Bool, shouldLogErrors: Bool) {
		ts = Teleswift(token, shouldLogVerbosely: shouldLogVerbosely, shouldLogErrors: shouldLogErrors, toTextView: toTextView)
		logView = toTextView
		ts.console.font = preferredFont
	}
	
	func run() {
		isRunning = true
		
		ts.console.verbosity("bot started", caller: "botprocess")
		
		while !stop {
			do {
				
				// insert bot code here
				
				while !stop {
					
					var toRestart = Bool(false)
					
					ts.console.textView = logView
					
					do {
						
						let lastLogStatus = ts.console.logVerbosely
						ts.console.logVerbosely = false
						let gotUpdates = try ts.getUpdates()
						if gotUpdates.count != 0 {try ts.clearUpdates(gotUpdates.last!.update_id)}
						ts.console.logVerbosely = lastLogStatus
						
						while !stop {
							
							let commandsToIterate = ts.discernCommands(updates: try ts.getAndClearUpdates(shouldFilter: self.shouldFilterSpam))
							for i in commandsToIterate {
								try autoreleasepool {
									print("Processing command \'\(i.command.components(separatedBy: "@").first!)\'")
									_ = try ts.sendChatAction(chat_id: i.fromMessage.chat.id, action: "typing")
									switch i.command.components(separatedBy: "@").first! {
									case "/ping":
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "\(getpid()): ping: \(try ts.ping()) ms")
									case "/id":
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "\(getpid()): id: \(i.fromMessage.chat.id)")
									case "/admins":
										if i.fromMessage.chat.type == "private" {_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "\(getpid()): No administrators in private chat"); break}
										var adminString = String()
										for j in try ts.getChatAdministrators(chat_id: i.fromMessage.chat.id) {adminString.append("\(j.user.first_name) \(j.user.last_name)".replacingOccurrences(of: "_", with: "").replacingOccurrences(of: "*", with: "") + ": @" + String(j.user.username) + "\n")}
										adminString.prepend("<strong>Administrators: Username</strong>\n")
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "\(getpid()): \(adminString)", parse_mode: "HTML")
									case "/idme":
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: ("\(getpid())" + ": " + i.fromMessage.from.first_name + ": " + String(i.fromMessage.from.id)))
									case "/start": break
									case "/random":
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: String(arc4random()))
									case "/test": _ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "Testing, 1, 2, 3")
									case "/crash": _ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "Crashing"); fatalError("Debug crash. Don't panic!") //crashes the program
									case "/restart": _ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "Restarting"); toRestart = true; break
									case "/forcetgerror": _ = try ts.sendMessage(chat_id: String(arc4random()), text: "If you have received this message in error, please ignore it.")
									case "/listoffences":
										var offenceString = String()
										for i in ts.sf.log {offenceString.append("\(i.user.first_name) (\(i.user.id)): \(i.count)\n")}
										offenceString.prepend("<strong>User: Offences</strong>\n")
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: offenceString, parse_mode: "HTML")
									case "/listexcommunicate":
										var excomString = String()
										for j in ts.sf.log where try ts.getChatMember(chat_id: i.fromMessage.chat.id, user_id: j.user.id).status != "left" && j.excommunicated {excomString.append("\(j.user.first_name) (\(j.user.id)): \(j.reliefTime) UTC\n")}
										excomString.prepend("<strong>User: Relief time</strong>\n")
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: excomString, parse_mode: "HTML")
									case "/pid": _ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "\(getpid())")
									case "/grabphotosfromid":
										let arrayOfPhotos = try ts.getUserProfilePhotos(user_id: i.fromMessage.text.components(separatedBy: " ").last!).photos
										for j in 0..<arrayOfPhotos.count {
											_ = try ts.sendPhoto(chat_id: i.fromMessage.chat.id, photo: arrayOfPhotos[j].last!.file_id, caption: "\(j+1) of \(arrayOfPhotos.count)")
										}
									default:
										_ = try ts.sendMessage(chat_id: i.fromMessage.chat.id, text: "\(getpid()): \(i.command.components(separatedBy: " ").first!) does not appear to be a valid command.")
									}
								}
								if toRestart {break}
							}
							sleep(updateFrequency)
							if toRestart {break}
						}
					}
					catch apiError.notOK {print("Invalid Request")}
					catch apiError.noConnection {print("No Internet connection detected")}
					catch classError.jsonNotAllValuesPresent(let err) {print("Not all required values are present. Missing: \(err)")}
					catch apiError.unknown(let err) {print(err)}
					catch classError.unknown(let err) {print(err)}
					catch apiError.invalidParameter(let err) {print(err)}
					catch tgError.unauthorized {print("Unauthorized. Token revoked?")}
					catch tgError.unknown(let err) {print(err)}
					catch tgError.chat_not_found {print("chat not found")}
					catch let err {print(err)}
				}
			}
		}
		isRunning = false
		ts.console.verbosity("bot stopped", caller: "botprocess")
	}
}

extension String {
	/// Adds the provided string to the front of the string.
	mutating func prepend(_ contentsOf: String) {self = contentsOf.appending(self)}
}
