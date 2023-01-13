# Tweets and Toots

This is the repo I will use to build a Shiny app that let's me schedule threads on both, Twitter and Mastodon.

## Current Status

A basic UI has been implemented that let's the user write threads of tweets and toots side by side.
Currently, new messages can be added to the thread by clicking "Add Msg".
Messages can be collected using the other button.
After collection, the messages are printed into the console (current status only) if they changed from the last collection

Next update: I'll continue development when I get back from vacation after January 15.

## Roadmap

### General

- Create a {renv}-controlled {golem} app for project

### UI

- Allow multiple image uploads
- Use separate amount of tweets and toots
- Fix automatic text area height adjustment for second row of text cards
- Make theme pretty with {fresh} or {bslib}
- Figure out why message collection does not work in RStudio web browser (currently low priority since it works in Firefox and Chrome)

### Backend

- Create backend functions to interact with Twitter ({rtweet}) and Mastodon API ({rtoot})
- Figure out how to store data permanently (after closing app)
- Figure out how to schedule tasks (i.e. schedule thread to be published as specified time)

