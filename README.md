# Pre-work - *Tip Calculator 3000*

*Tip Calculator 3000* is a tip calculator application for iOS.

Submitted by: Giovanni Propersi

Time spent: **16** hours spent in total

## User Stories

The following **required** functionality is complete:

* [X] User can enter a bill amount, choose a tip percentage, and see the tip and total values.
* [X] User can select between tip percentages by tapping different values on the segmented control and the tip value is updated accordingly
        - Updated to be a slider

The following **optional** features are implemented:

* [X] UI animations - Slider can be smooth or incremental, fly in animations
* [X] Remembering the bill amount across app restarts (if <10mins)
* [X] Using locale-specific currency and currency thousands separators.
* [X] Making sure the keyboard is always visible and the bill amount is always the first responder. This way the user doesn't have to tap anywhere to use this app. Just launch the app and start typing.

The following **additional** features are implemented:

- [X] Slider instead of segmented choice, with setting for max slider value.
- [X] Automatically calculates tip while user inputs bill amount. 
- [X] Prompts user with decimal keyboard only.
- [X] Dark Mode with varying view colors
- [X] Error messages in the settings menu if invalid values input
- [X] Locked autorotation into portrait mode only
- [X] Allows user to alternate currency chosen within the app

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='https://i.imgur.com/6AwfVl0.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

This being my first iOS app, the initial challenge involved becoming familiar with the iOS ecosystem at its most basic level. Challenges faced were as follows:
- Working with input/output from the user. Learned how to pull data from the input fields at different times in the input process.
- Working with user-preferred settings and developing a 'Settings' window to allow these settings to persist across the app.
- Setting colors for the unsafe area of a View, discovered when the 'Unsafe' area's white background was covering up the battery and clock display. Set to be the SystemBackground color.
- Determining how to see if 10 minutes had passed - just need a function to check the difference between two intervals in time.
- Placing horizontal dividing lines in a view - ended up just needing a label with a background color, and making it 1px thick.
- Forcing the app into only portrait mode took some digging on the internet...
- Constraining everything in the view before performing animations led to many constraint conflicts that
    led to a better definition of what constraints were needed.
- Currency conversion led to the need to store workable numerical/decimal values while also working with strings to display, and learning how to use
    a NumericalFormatter.


## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

