# Pre - milestone 1 meeting
The meeting was conducted on Slack at 8pm - 8:30pm on November 13th. The goal was to
answer all questions regarding milestone 1.

## What does our app do?
Our app is a marketplace for used bikes in the city of Davis. Users can upload
postings of their bikes and browse posts other people post.

## Sketches
We used Balsamiq to make preliminary sketches. They are available
[here](https://github.com/ECS189E/project-f19-tigers/blob/master/meeting_notes/view-mockup.pdf)

## 3rd party libraries
* Firebase for account support
* Firebase for server support

## Models
* User model - contains name, contact information, and all the postings the user has
* Posting - contains image(s), name of posting, description, date

## View Controllers
* Entry View Controller, goes to either:  
  * Marketplace if it's a returning user with login credentials
  * Other ViewControllers related to sign up

* Main Marketplace ViewController
  * Has a feed of postings in a ScrollView
  * Has Buttons to navigate to other View Controllers (Settings, New Postings, User's Postings)

* Settings View Controller
  * Has options to change password, username, delete account
  * Options implemented within UIAlertControllers

* New Posting View Controller
  * Allows user to add a new posting with a name, description, images

## Week long tasks
Before next milestone:  
* A workable UI
* Set up Firebase and account functionality
* Set up Firebase with the postings functionality (ability to store/retreive posts on Firebase)

## Testing plan
We will be asking our friends to try the app, and then provide feedback through
an anonymized Google Forms. We will do this whenever we implement a major feature,
try to have first testing after milestone 2.
