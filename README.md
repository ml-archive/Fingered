# Fingered  👈
A Protocol-based Touch ID wrapper written in Swift. Touch ID implementation is simple, but all of the extra logic around the actual use case requires a lot of work. Fingered simplifies this down to 3 calls and one protocol conformance. 

## 📝 Requirements
* iOS 8.0+
* Swift 3.0+

## 📦 Installation

### Carthage
~~~bash
github "nodes-ios/Fingered"
~~~

### Cocoapods and SPM
Coming soon

## 💻 Usage

There are three main entities in Fingered: A *Finger* 👈, the *Hand* ✋, and the *Ring* 💍. A Finger  is something that conforms to `Fingerable`. The Hand is what that **hand**les all of the interaction between a Finger, the Ring, and the app. The Ring is a metaphor for the stored credentials- Only one Finger can have the Ring, and it is this Finger that will be stored in the keychain for use with TouchID. 

First, you will need your user object to conform to the `Fingerable` protocol. This only requires one computed property, a unique identifier for your model. There is also an optional dictionary if you need to store additional information in keychain beyond the username and password. 

Next, there are three methods to be aware of that are provided by the Hand ✋. 

When a user logs in to your app successfully for the first time, you can check to see if they can be saved in the keychain for use with TouchID. Call the `proposeWithRingFor(finger:) throws` method to ensure that this user qualifies. If this returns `true`, you should prompt your user if they want to enable TouchID use. 
**NOTE**: This will only return true *once* per user, so that they are not asked repeatedly every time they log in. 

If the previous method returns true and your user accepts whatever UI message you present them, you can store their credentials by calling `placeRingOnFinger(finger: withVow: withReason: completion:)`, with the "vow" as the password the user has just used to log in with. This will prompt them to verify their TouchID fingerprint, and afterwards store the credentials in the keychain. 

The last piece to implement is the actual TouchID login. In your login view's viewWillAppear(animated:) (or whenever you want to attempt a TouchID login), call `verifyRingFinger(finger: withReason: completion:)` which will return a `RingFinger` tuple with the user's stored credentials if it was successful. Note that you will need to provide your own way of storing and retrieving previously logged in user identifiers. 

## 👥 Credits
Made with ❤️ at [Nodes](http://nodesagency.com).

## 📄 License
**Fingered** is available under the MIT license. See the [LICENSE](https://github.com/nodes-ios/Fingered/blob/master/License.txt) file for more info.