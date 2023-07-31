/* global describe, context it, beforeEach, afterEach */

const Helper = require('hubot-test-helper');
const chai = require('chai');
chai.use(require('sinon-chai'));
const nock = require('nock');

const helper = new Helper('./../src/mailchimp.js');
const { expect } = chai;

describe('mailchimp basic operations', () => {
  let room = null;

  beforeEach(() => {
    process.env.MAILCHIMP_API_KEY = 'foo123bar456baz-us';
    process.env.MAILCHIMP_LIST_ID = '123foo456';
    process.env.MAILCHIMP_SERVER_PREFIX = 'us10';
    room = helper.createRoom();
    nock.disableNetConnect();
  });

  afterEach(() => {
    room.destroy();
    nock.cleanAll();
    delete process.env.MAILCHIMP_API_KEY;
    delete process.env.MAILCHIMP_LIST_ID;
    delete process.env.MAILCHIMP_SERVER_PREFIX;
  });

  context('subscribe a user', () => {
    beforeEach((done) => {
      nock('https://us10.api.mailchimp.com')
        .post('/3.0/lists/123foo456/members')
        .replyWithFile(200, 'test/fixtures/subscriber-subscribed.json');
      room.user.say('alice', '@hubot subscribe johndoe@example.com');
      setTimeout(done, 100);
    });

    it('hubot responds with message', () => expect(room.messages).to.eql([
      ['alice', '@hubot subscribe johndoe@example.com'],
      ['hubot', '@alice Attempting to subscribe johndoe@example.com...'],
      ['hubot', 'You successfully subscribed johndoe@example.com.'],
    ]));
  });

  context('unsubscribe a user', () => {
    beforeEach((done) => {
      nock('https://us10.api.mailchimp.com')
        .delete('/3.0/lists/123foo456/members/fd876f8cd6a58277fc664d47ea10ad19')
        .reply(204);
      room.user.say('alice', '@hubot unsubscribe johndoe@example.com');
      setTimeout(done, 100);
    });

    it('hubot responds with message', () => expect(room.messages).to.eql([
      ['alice', '@hubot unsubscribe johndoe@example.com'],
      ['hubot', '@alice Attempting to unsubscribe johndoe@example.com...'],
      ['hubot', 'You successfully unsubscribed johndoe@example.com.'],
    ]));
  });

  context('get latest campaign stats', () => {
    beforeEach((done) => {
      nock('https://us10.api.mailchimp.com')
        .get('/3.0/campaigns')
        .query({
          offset: 0,
          count: 1,
          status: 'sent',
          sort_field: 'send_time',
          sort_dir: 'desc',
        })
        .replyWithFile(200, 'test/fixtures/campaigns.json');
      room.user.say('alice', '@hubot mailchimp');
      setTimeout(done, 100);
    });

    it('hubot responds with message', () => expect(room.messages).to.eql([
      ['alice', '@hubot mailchimp'],
      ['hubot', 'Last campaign "Poll test" was sent to 1 subscribers (1 opened, 0 clicked)'],
    ]));
  });
});
