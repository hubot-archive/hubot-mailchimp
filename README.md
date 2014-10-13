# Hubot-Mailchimp

Mailchimp hubot script as an NPM package
Request the mailchimp API from campfire/hipchat or anywhere you can join hubot.


## Installation

Add 'hubot-mailchimp' to your `package.json` file, e.g.

```json
  "dependencies": {
    "hubot": ">= 2.6.0 < 3.0.0",
    "hubot-scripts": ">= 2.5.0 < 3.0.0",
    "hubot-hipchat": "~2.6.4",
    "hubot-mailchimp": "~1.1.3"
  }
```

Then add 'hubot-mailchimp' to your `external_scripts.json` file and run `npm install`.


## Config

    MAILCHIMP_API_KEY
	MAILCHIMP_LIST_ID

## Commands

    hubot subscribe <email> - Add email to list
    hubot unsubscribe <email> - Remove email from list
