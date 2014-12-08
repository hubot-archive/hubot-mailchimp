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
#   hubot mailchimp - Get statistics from latest mailing
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
  robot.respond /\bmailchimp/i, (message) ->
    latestCampaign

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

latestCampaign = (message) ->

  try
    api = new MailChimpAPI(apiKey,
      version: "1.3"
      secure: false
    )
  catch error
    console.log error.message
    return

  api.campaigns { start: 0, limit: 1 }, (error, data) ->
    if error
      message.send "Uh oh, something went wrong: #{error.message}"
    else
      # Get the first campaign in the list
      cid = data['data'][0]['id']
      campaign_name = data['data'][0]['title']

      api.campaignStats { cid : cid }, (error, data) ->
        if error
          message.send "Uh oh, something went wrong: #{error.message}"
        else
          stats = data['data']
          message.send "Last campaign \"#{campaign_name}\" was sent to #{stats['emails_sent']} subscribers (#{stats['unique_opens']} opened, #{stats['unique_clicks']} clicked, #{stats['unsubscribes']} unsubscribed)"
