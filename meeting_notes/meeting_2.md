# Meeting 2 Minutes

Meeting started at 11:30am on 11/11.  

## Major project changes
We decided to change our project from an end-to-end encryption chat application to a
marketplace for bikes in Davis. This is because we could not figure out a way to
make the chat unique and distinct from all the other apps, and a marketplace for
bikes in Davis would be more unique.

## Key points about the app
We agreed that we will aim to create an app with the most basic functionality as
soon as possible. We will then create more complicated features. Here are the
key points we agreed we need to have though:  

* A new user will need a phone number to create an account.  
* Once they have an account they will log in using a password.
* App will have profile customization: changing username, password.
* It will feature a "news feed" with all the postings about bikes.
* We will initially not implement messaging functionality; this will come after
we develop a minimally functional app if we have time left.

## Coding conventions
We defined some coding conventions for our group to make navigating other people's
code easier.
* Define variables at the top: IBOutlets first and then other variables.
* view.didLoad() as first function.
* Button clicks next
* Helper methods come next.
* At the bottom are delegate/protocol functions.

## Git usage
New features will be on their own branch. For pull requests, other members of the
group will review code. All comments/change requests must be addressed before
merging to master. Filip will provide a gitignore.

## Testing process
We will be asking our friends to try the app, and then provide feedback through
an anonymized Google Forms.

# UI proposal
Vsevolod came up with a proposal of what each ViewController should look like.
07:56pm: I added a PDF containing the view mockup to the repo.
The mockup can be found [here](https://github.com/ECS189E/project-f19-tigers/commit/36c9db26cd493a196331993efed7437ca523fca1).


Meeting ended at 12:45pm. Here is the [link](https://trello.com/b/54TKPcGT/ecs189e-project) to Trello.
