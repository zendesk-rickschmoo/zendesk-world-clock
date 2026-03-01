Create a  MacOS menu bar app called "Zendesk World Clock"

# Phase 1

## How it should work
- Shows a small icon in the top menu bar (like the battery icon)
- When I click the icon, a dropdown appears showing times in cities with Zendesk offices
- Menu bar only, no dock icon

## UI Design
- Header row in UI contains
  - App icon (globe) and the app name
  - Small gear button on e right for settings
- Simple styling, matching MacOS system styling
- Then a list of the cities
  - Each row contains a work hours indicator (coloured circle) on the left
  - The city name
  - The current timezone in brackets after the city
  - The current time in HH:mm 24-hour format (right aligned)


## Cities to show

- Honululu, San Francisco, Austin, Madison, Montréal, Mexico City, São Paulo, Amsterdam, Berlin, Copenhagen, Dublin, Kraków, Lisbon, London, Milan, Novi Sad, Paris, Tallinn, Bengaluru, Melbourne, Pune, Seoul, Singapore, Taguig, Tokyo

Sort the cities from west to east (earliest time to latest time)

## Work hours indicator
- Green if the city time is between 8am and 6pm
- Orange if the city time is 7-8am or 6-7pm
- Red otherwise

## Settings
- Clicking the settings button opens a settings screen
- Include a toggle to switch between 12 and 24 hour time
- Default to 24 hour format
- Remember the user's settings when the app restarts

## Functionality
- Times should update in real-time
- Clean, minimal design matching the MacOS aesthetic

## Things for you to do
- Prompt me with questions before coding
- Handle all the Xcode commands for me
- Keep a summary of everything we've done in a README.md, useful command etc.
- 

# Phase 2
- Only when the above is completed, add the ability for the user to hide cities. To do this, please add an "eye" icon on each row to the right of the time
- Clicking this icon removes the city immediately
- Enhance the settings page to show the hidden cities and provide the ability to reshow them


