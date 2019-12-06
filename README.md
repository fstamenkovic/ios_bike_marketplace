# Tigers 189E Project Repo.  

## App Description

Our application is a marketplace for used bikes. The problem that we are trying
to solve is to make it easier to buy a used bike in Davis. Normally, people look
for bike over Facebook and Craigslist, which are not platforms that are
dedicated for buying a used bike. Because of this, people find it difficult to
find a bike they want.  

Our app solves this problem by tracking user preferences in terms of which bikes
they view, and it notifies them when a bike they might like comes on the market.  

We used Firebase for our database and storage. We also made use of Firebase
Functions and the Twilio to support our magic experience.

## App flow and structure

### Accounts
When a user opens an app, they can either log in with an existing account or
create a new one. If they create a new one, basic information such as username,
password, and phone number will be taken.

### Bike feed
The bike feed is the heart of the app. It shows all bike postings (excluding
user's own postings), and it sorts them in the order of what user preferences
based on what they've recently clicked. The user has an option to create a new
posting, or manage their account and their own postings through the "Settings"
button.

### Magic Experience
When a user views a bike posting, the app updates their preferences. When
another user makes a posting that matches the color and category of the user's
preferences, it send the user a text message notifying them that a bike they
might like is available. As soon as they log into the app, they are prompted if
they would like to view the posting of interest.  

The way that this works is using Firebase Functions and the Twilio API. When
someone makes a new posting, the app invokes a
[Firebase Function](https://github.com/ECS189E/project-f19-tigers/blob/master/firebase_functions/functions/index.js) that searches through all the users, and finds ones that match the
preferences of the new postings. The Firebase function then makes a call on the
Twilio API to send the text to users who might be interested in the bike.

**Important note:** in order to receive texts, Twilio requires you to verify
your number with our project because we currently have a trial account. Trying
to trigger the magic experience with an unverified number will not work.

## Running the App

Simply run the app through the workspace in the bike/marketplace directory.

## Contributions

### Filip Stamenkovic <https://github.com/fstamenkovic>

- Enabled magic experience using Firebase Functions and Twilio.
- Created the Bike Feed.
- Created a way to add and delete postings.
- Designed a way to track user preferences.
- Ensured UI constraints run well on all phones down to iPhone 8.
- Managed git dependencies for the project to ensure a clean history and smooth
feature integration.

### Vsevolod Moskaev <https://github.com/meucd>

- Responsible for UI layout and initial setup.
- Set up Firebase with our project.
- Responsible for keeping Trello board up to date.
- Implemented the user login/signup experience.
- Ensured that account deletion removes all associated postings.

### Ryland Sepic <https://github.com/rmsepic>

- Responsible for meeting minutes and documentation.
- UI setup for login.
- Picture support for the app, letting a user load photos into the app from
their library.
- Created swiping functionality for images.
- Firebase storage setup for images.
- Linked the Firebase storage to the application.
