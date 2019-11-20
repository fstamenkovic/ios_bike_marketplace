# Documentation regarding UI layout of the project

Currently, we have two storyboards:
* Main.storyboard, which deals with accounts.
* marketlace.storyboard, which deals with the mainframe of the app.  

The purpose for this is to hopefully make it possible to work on both aspects of
the app in parallel. Having the same storyboard will lead to very difficult
merge conflicts as storyboards are XML files.

## Flow
The app always starts with the Login interface on Main.storyboard. The flow is
controlled by a Navigation Controller. This makes it easy to pop back to the
root View Controller once the login or signup flow is finished and the user goes
on to use the app. This is important because when the user clicks logout, we do
not want to take them to the phone entry view controller, but to the login view
controller. If we use present() all to control the flow of the signup process,
we have no clean way of doing this.  

When switching between Main.storyboard and marketlace.storyboard, we set the
main View Controller on in marketlace.storyboard as the root of a newly created
Navigation Controller, and then we present the Navigation Controller. We can
then pop back to the root View Controller in Main.storyboard so that when the
user logs out, they get to the login interface.

The marketplace.storyboard is also controlled by a Navigation Controller, for
the same reasons.
