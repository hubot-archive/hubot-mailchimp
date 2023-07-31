// Description:
//   Add or remove members to a mailing list and get a report of your latest sent campaign.
//
// Dependencies:
//   "mailchimp": "1.1.0"
//
// Configuration:
//   MAILCHIMP_API_KEY
//   MAILCHIMP_LIST_ID
//   MAILCHIMP_SERVER_PREFIX
//
// Commands:
//   hubot subscribe <email> - Add email to list
//   hubot unsubscribe <email> - Remove email from list
//   hubot mailchimp - Get statistics from latest mailing
//
// Author:
//   max, lmarburger, m-baumgartner, sporkmonger, stephenyeargin

const crypto = require('crypto');
const mailchimp = require('@mailchimp/mailchimp_marketing');

const apiKey = process.env.MAILCHIMP_API_KEY;
const listId = process.env.MAILCHIMP_LIST_ID;
const server = process.env.MAILCHIMP_SERVER_PREFIX;

module.exports = (robot) => {
  mailchimp.setConfig({
    apiKey,
    server,
  });

  // Subscribe an email address
  robot.respond(/subscribe (.+@.+)/i, async (message) => {
    const emailAddress = message.match[1];
    message.reply(`Attempting to subscribe ${emailAddress}...`);

    const params = {
      email_address: emailAddress,
      status: 'subscribed',
    };

    await mailchimp.lists.addListMember(listId, params)
      .then((jsonResponse) => {
        robot.logger.debug(jsonResponse);
        return message.send(`You successfully subscribed ${emailAddress}.`);
      })
      .catch((error) => {
        robot.logger.error(error);
        return message.send(`Uh oh, something went wrong: ${error.message}`);
      });
  });

  // Unsubscribe an email address
  robot.respond(/unsubscribe (.+@.+)/i, async (message) => {
    const emailAddress = message.match[1];
    const emailHash = crypto.createHash('md5').update(emailAddress).digest('hex');
    message.reply(`Attempting to unsubscribe ${emailAddress}...`);

    await mailchimp.lists.deleteListMember(listId, emailHash)
      .then((jsonResponse) => {
        robot.logger.debug(jsonResponse);
        message.send(`You successfully unsubscribed ${emailAddress}.`);
      })
      .catch((error) => {
        robot.logger.error(error);
        message.send(`Uh oh, something went wrong: ${error.message}`);
      });
  });

  // Get statistics for last campaign
  robot.respond(/mailchimp/i, async (message) => {
    await mailchimp.campaigns.list({
      count: 1,
      offset: 0,
      status: 'sent',
      sort_field: 'send_time',
      sort_dir: 'desc',
    })
      .then((jsonResponse) => {
        robot.logger.debug(jsonResponse);
        const response = JSON.parse(jsonResponse);
        // Get the first campaign in the list
        if (response.total_items > 0) {
          const campaign = response.campaigns[0];
          message.send(`Last campaign "${campaign.settings.title}" was sent to ${campaign.emails_sent} subscribers (${campaign.report_summary.unique_opens} opened, ${campaign.report_summary.clicks} clicked)`);
        } else {
          message.send('No recent campaigns sent.');
        }
      })
      .catch((error) => {
        robot.logger.error(error);
        message.send(`Uh oh, something went wrong: ${error.message}`);
      });
  });
};
