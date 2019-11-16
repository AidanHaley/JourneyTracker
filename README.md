# JourneyTracker

This is a simple tracking application which utilises mapKit to collect and store the journeys which the user takes and displays details about them.
The app also shows the route of the current journey taken as well as displays the previous routes on a seperate map.


## Getting Started

The app does not use any external frameworks so will not require any setting up.

If using simulator you will need to ensure a location is being displayed to the app, to test out all the features of the app correctly,
I recommend selecting: Debug > Location > City Run, this will give you the best results running the app this way.

<img width="422" alt="Screenshot 2019-11-16 at 05 59 06" src="https://user-images.githubusercontent.com/23657057/68989075-ab667c80-0839-11ea-9cb8-161f4e702ed0.png">

## Using the App

The app is fairly straightforward, to start tracking your location toggle the 'Tracking on/off' switch and select the map tab to start tracking your current journey and view it being recorded.

Once you are finished recording a journey, toggle the switch off to end tracking and save to the app, saved journeys can be viewed on the 'journeys' tab, selecting a journey in the table will display the route on a map.

## Navigating the Code

The Data Model for this project can be found in the 'Models' folder along with a Core Data Manager class which is a stack. The Services folder contains a singleton class which allows the view controllers to communicate with eachother to allow tracking to be managed effectively. the resources folder contains all UI Elements while the resources folder contains all misc resources such as assets and info.plist.

The structure and layout of each view controller class is marked out for easy navigation.

## Questions and Feedback

All questions and feedback are welcome!

Please don't hesitate to contact me at:
Aidan.h95@outlook.com
