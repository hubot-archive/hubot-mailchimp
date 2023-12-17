# Mailchimp for Hubot

[![npm version](https://badge.fury.io/js/hubot-mailchimp.svg)](http://badge.fury.io/js/hubot-mailchimp) [![Node CI](https://github.com/hubot-archive/hubot-mailchimp/actions/workflows/nodejs.yml/badge.svg)](https://github.com/hubot-archive/hubot-mailchimp/actions/workflows/nodejs.yml)

Use Hubot to add or remove members to a mailing list and get a report of your latest sent campaign.

## Installation

In the Hubot project repo, run:

```bash
npm install hubot-mailchimp --save
```

Then add `hubot-mailchimp` to your `external-scripts.json`:

```json
[
  "hubot-mailchimp"
]
```

## Configuration

| Configuration Variable    | Required | Description                                |
| ------------------------- | -------- | ------------------------------------------ |
| `MAILCHIMP_API_KEY`       | **Yes**  | API key for your Hubot integration         |
| `MAILCHIMP_LIST_ID`       | **Yes**  | The unique identifier for the desired list |
| `MAILCHIMP_SERVER_PREFIX` | **Yes**  | Server identifier, e.g. `us10`             |

## Sample Interaction

### Add a member to the list by email

```
User> @hubot subscribe johndoe@example.com
Hubot> @user Attempting to subscribe johndoe@example.com...
Hubot> You successfully subscribed johndoe@example.com.
```

### Remove a member from the list by email

```
User> @hubot unsubscribe johndoe@example.com
Hubot> @user Attempting to unsubscribe johndoe@example.com...
Hubot> You successfully unsubscribed johndoe@example.com.
```

### Get the report from your latest sent campaign

```
User> @hubot mailchimp
Hubot> Last campaign "My Awesome Campaign" was sent to 431 subscribers (310 opened, 225 clicked)
```
