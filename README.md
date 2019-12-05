# Tigers 189E Project Repo.  

## App Description

Our application is a markeplace for used bikes. A user is required to create their account with a username, password, and to list a valid phone number. The user is able to create a posting listing a category and color for the bike, as well as being able to set a description and add photos. 

On a bike feed, all of the listed bikes that the user did not post will be present, as to avoid clutter. The user can choose bikes based on their categories. In the view of the specific listing the user can view photos of the bike, the description, as well as find the contact information of the poster.

If another posting is made that is similar to the ones the user is clicked on they will recieve an SMS notification. The notificaton lets the user know that a bicycle they may be interested in has just been posted. They can enter the application and view the newly listed item. 

## Running the App

To properly run the app click on the *bike_marketplace.xcworkplace* to load a version that properly loads the Pod files associated with the project.

## Contributions

Filip Stamenkovic 
<https://github.com/fstamenkovic>

- Kept track of the git history and version control
- Separated storyboards and took care of movement between view controllers [link] (https://github.com/ECS189E/project-f19-tigers/commit/8084b4ce19f48a8bc0c33b9cae1d92a00c26821d)
- Setup the bike feed [link](https://github.com/ECS189E/project-f19-tigers/commit/5c5be52246919a42c6006dc575f30ebe8fd05d3a)
    + Bike feed was synchronized with Firebase 
    + Modified bike feed so that user's own postings would not show in the bike feed
- Added a view for a single posting [link](https://github.com/ECS189E/project-f19-tigers/commit/b5c6fb976bfc90010175e69e2dc4de98e1b71646)
- Ability to delete a posting [link](https://github.com/ECS189E/project-f19-tigers/commit/f1edc9f168707ef4851c5a5f8c80e83c866fe849)
- Refractored the UI [link](https://github.com/ECS189E/project-f19-tigers/commit/038921957b3e31d125c9bce31699c9c27787d433)
    + Implemented multithreading into certain parts of the applicatoin
- Implemented the recommendation experience [link](https://github.com/ECS189E/project-f19-tigers/commit/1b746a281dce96e275208e8c1c6a989a0912aca4)
    + SMS messages 

Vsevolod Moskaev 
<https://github.com/meucd>

- Responsible for UI layout and initial setup [link](https://github.com/ECS189E/project-f19-tigers/commit/36c9db26cd493a196331993efed7437ca523fca1)
    + Created drawings
- Responsible for keeping Trello board up to date
- Firebase setup [link](https://github.com/ECS189E/project-f19-tigers/commit/e447310efb58b56a7a8f00488e20393d89aa5698)
    + Initial Firebase setup: created the Firebase objects that stored information about users and postings
- UI improvments [link](https://github.com/ECS189E/project-f19-tigers/commit/782b680d79cbf3bb92a3997dea7df317e3158b4c)
    + Setting up lables and errors
-  Password setup [link](https://github.com/ECS189E/project-f19-tigers/commit/95d39e3db5c718107a1a6cf69021bfbb9adc1748)
-  Creation and deletion of accounts [link](https://github.com/ECS189E/project-f19-tigers/commit/656982370047513db74fe9727e72e8bd954aafe4)
    +  Password verification for when an account will be deleted
- Improved deletion of an account [link](https://github.com/ECS189E/project-f19-tigers/commit/04a4660a916140e82c6a6382928f5c513df617e6)
    + Delete the photos from storage
    + Implemented parallel queues for deletion 

Ryland Sepic 
<https://github.com/rmsepic>

- Responsible for meeting minutes and documentation
- UI setup for login [link](https://github.com/ECS189E/project-f19-tigers/commit/d52c9336895f05b4c41f3e260e653eb5e8a5ef6e)
- Picture support for the app [link](https://github.com/ECS189E/project-f19-tigers/commit/009e042dd654a25da58f3492684dd879e85eda97)
    + Linked up the application to the user's photo library so that they can select photos
    + Allowed for user to be able to remove pictures before uploading them [link](https://github.com/ECS189E/project-f19-tigers/commit/7b3de15ea973defe10c0f2e5bd6ba9087f0d496c)
- Created a swiping functionality for images so that the users can cycle through the pictures associated with a post [link](https://github.com/ECS189E/project-f19-tigers/commit/cca18b4a5cc741fc7ba8d30344f10c86cb6abeff)
    + Used UIImageView and linked them to swipe gestures
- Firebase storage setup [link](https://github.com/ECS189E/project-f19-tigers/commit/19418a575917a7cad67314908a2a2244e57d795b)
- Linked the Firebase storage to the application [link](https://github.com/ECS189E/project-f19-tigers/commit/1258385d1725a1ec0dd0a21d52e1242e3fce452e)
    + User stores photo ID's in their post and the ID's correspond to the images that are in storage
    + Recover the photos from storage using the ID's
   
