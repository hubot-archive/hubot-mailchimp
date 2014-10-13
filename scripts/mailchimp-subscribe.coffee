# Description:
#   Add email to Mailchimp list
#
# Dependencies:
#   "mailchimp": "1.1.0"
#
# Configuration:
#   MAILCHIMP_API_KEY
#   MAILCHIMP_LIST_ID
#
# Commands:
#   hubot subscribe <email> - Add email to list
#   hubot unsubscribe <email> - Remove email from list
#
# Author:
#   max, lmarburger, m-baumgartner, sporkmonger

MailChimpAPI = require('mailchimp').MailChimpAPI

apiKey = process.env.MAILCHIMP_API_KEY
listId = process.env.MAILCHIMP_LIST_ID

module.exports = (robot) ->
  robot.respond /\bsubscribe (.+@.+)/i, (message) ->
    subscribeToList message
  robot.respond /\bunsubscribe (.+@.+)/i, (message) ->
    unsubscribeFromList message

subscribeToList = (message) ->
  emailAddress = message.match[1]
  message.reply "Attempting to subscribe #{emailAddress}..."

  try
    api = new MailChimpAPI(apiKey,
      version: "1.3"
      secure: false
    )
  catch error
    console.log error.message
    return

  api.listSubscribe
    id:            listId
    email_address: emailAddress
    double_optin:  false
  , (error, data) ->
    if error
      message.send "Uh oh, something went wrong: #{error.message}"
    else
      message.send "You successfully subscribed #{emailAddress}."

unsubscribeFromList = (message) ->
  emailAddress = message.match[1]
  message.reply "Attempting to unsubscribe #{emailAddress}..."

  try
    api = new MailChimpAPI(apiKey,
      version: "1.3"
      secure: false
    )
  catch error
    console.log error.message
    return

  api.listUnsubscribe
    id:            listId
    email_address: emailAddress
    double_optin:  false
  , (error, data) ->
    if error
      message.send "Uh oh, something went wrong: #{error.message}"
    else
      message.send "You successfully unsubscribed #{emailAddress}."
