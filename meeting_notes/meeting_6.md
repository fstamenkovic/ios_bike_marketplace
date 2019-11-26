# Meeting 26 November 2019

Meeting Began 1115 (11:15am) and was conducted in person.

## Updates

* Filip updated the bike feed [link](https://github.com/ECS189E/project-f19-tigers/commit/b5c6fb976bfc90010175e69e2dc4de98e1b71646)
	* Implemented view Controller to show a single posting when selected in the feed
	* Implemented delegate/protocol relationship between the bike feed and new posting view controller. When the user posts to the database, the bike feed is updated.
* Vsevolod [link](https://github.com/ECS189E/project-f19-tigers/commit/782b680d79cbf3bb92a3997dea7df317e3158b4c)
	* Improved UI
		* Reorganized database
		* Changed password protocol (8 character limit and special characters)
		* Improve user experience 
			* Modified error messages
* Ryland [link](https://github.com/ECS189E/project-f19-tigers/commit/009e042dd654a25da58f3492684dd879e85eda97)
	* Added picture support to application 
	* Application checks the device for photo library
		* Makes sure the application has ability and proper access
	* User can access the photos and select pictures for their bicycle

## Future Plans 

* Cleanup database

Vsevolod: 
* Logout 
* Delete

Ryland:
* Set up profile picture 
* Support multiple photos (limited at 3) TOP PRIORITY 
* ViewPostingViewController
	* Blank UIPicture element that Filip can load images onto the UI

Filip:
* Storing photos onto Firebase
* Completing storing for posting
* Getting user's reference to postings

### Recommendation System 

* Store count of which category/color the user prfers 
	* Update their choice onto Firebase
* Algorithm that will show recommended feed in market place 

### Design

* Follow the login template designed by Vsevolod

## Long Term Plans 

* Considering publishing to the App store next quarter 
	* New database

Meeting ended at 1215 (12:15pm). 
Trello link [link](https://trello.com/b/54TKPcGT/ecs189e-project).


