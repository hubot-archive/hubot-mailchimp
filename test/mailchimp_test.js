const {
  describe, it, beforeEach, afterEach,
} = require('node:test');
const assert = require('node:assert/strict');
const nock = require('nock');
const { createTestBot } = require('./common/TestBot');

describe('mailchimp basic operations', () => {
  let bot;

  beforeEach(async () => {
    bot = await createTestBot();
  });

  afterEach(() => {
    bot.shutdown();
  });

  it('subscribes a user', async () => {
    nock('https://us10.api.mailchimp.com')
      .post('/3.0/lists/123foo456/members')
      .replyWithFile(200, `${__dirname}/fixtures/subscriber-subscribed.json`);

    const response = await bot.sendAndWaitForResponse('@hubot subscribe johndoe@example.com');
    assert.equal(bot.replies[0], 'Attempting to subscribe johndoe@example.com...');
    assert.equal(response, 'You successfully subscribed johndoe@example.com.');
  });

  it('unsubscribes a user', async () => {
    nock('https://us10.api.mailchimp.com')
      .delete('/3.0/lists/123foo456/members/fd876f8cd6a58277fc664d47ea10ad19')
      .reply(204);

    const response = await bot.sendAndWaitForResponse('@hubot unsubscribe johndoe@example.com');
    assert.equal(bot.replies[0], 'Attempting to unsubscribe johndoe@example.com...');
    assert.equal(response, 'You successfully unsubscribed johndoe@example.com.');
  });

  it('gets latest campaign stats', async () => {
    nock('https://us10.api.mailchimp.com')
      .get('/3.0/campaigns')
      .query({
        offset: 0,
        count: 1,
        status: 'sent',
        sort_field: 'send_time',
        sort_dir: 'desc',
      })
      .replyWithFile(200, `${__dirname}/fixtures/campaigns.json`);

    const response = await bot.sendAndWaitForResponse('@hubot mailchimp');
    assert.equal(response, 'Last campaign "Poll test" was sent to 1 subscribers (1 opened, 0 clicked)');
  });
});
