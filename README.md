# teleswift
Teleswift is a Swift 3-based SDK for the Telegram Bot API based on [Freddy JSON](https://github.com/bignerdranch/Freddy) (check it out!) designed with the aim of providing functionality for the Telegram Bot API in the Swift language for OS X.

The framework is written in Swift 3 and designed for use on for OS X. It includes a basic, configurable spam filter that is capable of removing what it thinks to be spam as defined by the programmer, warn users not to spam and *excommunicate*<sup>1</sup> them.

<sub><sup>1</sup>By *excommunication*, it is meant that the bot will no longer respond to their commands for a specified duration of time.</sub>

---

## Installation
You can download the precompiled framework from GitHub under the name `Teleswift.framework`.

Add the framework to your Xcode target's "Embedded Binaries" or "Linked Frameworks" list under Project > [Target] > Build Phases.

## Example usage

### Defining an instance of Teleswift
Teleswift can be defined just as any other class in Swift would be. Initialising the class requires the bot token.
```Swift
import Teleswift

let token = <your bot token here>
let ts = Teleswift(token)
```

### Calling a method
Calling methods in Teleswift is as natural as calling `print()`. Simply call the method you wish to call from the Teleswift instance you have created.
```Swift
ts.getMe() // returns a User object
```

### Properties
Accessing properties returned by a method can be performed by chaining in Swift. For example, consider the output returned by the function `getMe()`. The function returns a `User` object, which contains the following sub-properties:
```Swift
class User {
	/// Unique identifier for this user or bot
	open var id: Int
	/// User's or bot's first name
	open var first_name: String
	/// Optional. User's or bot's last name
	open var last_name: String
	/// Optional. User's or bot's username
	open var username: String
}
```
Accessing the username of the `User` object as simple as the following:
```Swift
let me = getMe()
let myUsername = me.username
```
Alternatively, to make code more compact and readable, the following works too:
```Swift
let myUsername = getMe().username
```

### Getting and accessing updates
Accessing updates in Swift is simple. The method used to receive updates is `getUpdates()`, and returns an array of `Update` objects. These `Update` objects contain information like the update ID, the `Message` that was sent and if any, an edited `Message`.
```Swift
let updates: [Update] = ts.getUpdates() // returns an array of Update objects in native Teleswift types.
let senderOfMessage = updates.message.from.id
let updateID = updates.update_id
```

## Example Source
The directory [teleswift-test-gui](https://github.com/perhapsmaybeharry/teleswift/tree/master/teleswift-test-gui) contains a somewhat-user-friendly GUI wrapper oriented around designing your first Teleswift-based bot. Example code is provided.

## Requirements
- Xcode 8 (Swift 3)
- OS X 10.10 (Swift support)

## License
Teleswift is licensed under the **MIT License**. Accreditation is appreciated where Teleswift is used.
