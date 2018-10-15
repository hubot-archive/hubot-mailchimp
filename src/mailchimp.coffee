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
#   max, lmarburger, m-baumgartner, sporkmonger, stephenyeargin

Mailchimp = require('mailchimp-api-v3')
crypto = require('crypto')

apiKey = process.env.MAILCHIMP_API_KEY
listId = process.env.MAILCHIMP_LIST_ID

module.exports = (robot) ->
  robot.respond /\bsubscribe (.+@.+)/i, (message) ->
    subscribeToList message
  robot.respond /\bunsubscribe (.+@.+)/i, (message) ->
    unsubscribeFromList message
  robot.respond /\bmailchimp/i, (message) ->
    latestCampaign message

subscribeToList = (message) ->
  emailAddress = message.match[1]
  message.reply "Attempting to subscribe #{emailAddress}..."

  try
    api = new Mailchimp(apiKey)
  catch error
    console.log error.message
    return

  api.request {
    method: 'post',
    path: "/lists/#{listId}/members",
    body: {
      email_address: emailAddress,
      status: 'subscribed'
    }
  }, (error, data) ->
    if error
      message.send "Uh oh, something went wrong: #{error.message}"
    else
      message.send "You successfully subscribed #{emailAddress}."

unsubscribeFromList = (message) ->
  emailAddress = message.match[1]
  emailHash = crypto.createHash('md5').update(emailAddress).digest('hex')
  message.reply "Attempting to unsubscribe #{emailAddress}..."

  try
    api = new Mailchimp(apiKey)
  catch error
    console.log error.message
    return

  api.request {
    method: 'delete',
    path: "/lists/#{listId}/members/#{emailHash}"
  }, (error, data) ->
    if error
      message.send "Uh oh, something went wrong: #{error.message}"
    else
      message.send "You successfully unsubscribed #{emailAddress}."

latestCampaign = (message) ->

  try
    api = new Mailchimp(apiKey)
  catch error
    console.log error.message
    return

  api.request {
    method: 'get',
    path: 'campaigns',
    query: {
      start: 0,
      limit: 1,
      status: 'sent'
    }
  }, (error, data) ->
    if error
      message.send "Uh oh, something went wrong: #{error.message}"
    else
      # Get the first campaign in the list
      if data['campaigns'].length > 0
        campaign = data['campaigns'][0]
        message.send "Last campaign \"#{campaign['settings']['title']}\" was sent to #{campaign['emails_sent']} subscribers (#{campaign['report_summary']['unique_opens']} opened, #{campaign['report_summary']['clicks']} clicked)"
      else
        message.send 'No recent campaigns sent.'
