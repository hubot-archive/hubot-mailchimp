const path = require('path');
const { Robot, TextMessage } = require('hubot');
const nock = require('nock');
const script = require('../../src/mailchimp');

class TestBotContext {
  constructor(robot, user) {
    this.robot = robot;
    this.user = user;
    this.sends = [];
    this.replies = [];
    this.robot.adapter.on('send', (_, strings) => this.sends.push(strings.join('\n')));
    this.robot.adapter.on('reply', (_, strings) => this.replies.push(strings.join('\n')));
    this.nock = nock;
  }

  async send(message) {
    const id = (Math.random() + 1).toString(36).substring(7);
    this.robot.adapter.receive(new TextMessage(this.user, message, id));
    await new Promise((done) => { setTimeout(done, 100); });
  }

  async sendAndWaitForResponse(message, responseType = 'send') {
    return new Promise((done) => {
      this.robot.adapter.once(responseType, (_, strings) => done(strings[0]));
      this.send(message);
    });
  }

  shutdown() {
    delete process.env.MAILCHIMP_API_KEY;
    delete process.env.MAILCHIMP_LIST_ID;
    delete process.env.MAILCHIMP_SERVER_PREFIX;
    nock.cleanAll();
    this.robot.shutdown();
  }
}

async function createTestBot(settings = {}) {
  process.env.HUBOT_LOG_LEVEL = 'silent';
  process.env.MAILCHIMP_API_KEY = settings.MAILCHIMP_API_KEY || 'foo123bar456baz-us';
  process.env.MAILCHIMP_LIST_ID = settings.MAILCHIMP_LIST_ID || '123foo456';
  process.env.MAILCHIMP_SERVER_PREFIX = settings.MAILCHIMP_SERVER_PREFIX || 'us10';
  nock.cleanAll();
  nock.disableNetConnect();
  const robot = new Robot(path.resolve(__dirname, 'adapter'), false, 'hubot');
  await robot.loadAdapter(path.resolve(__dirname, 'adapter.js'));
  script(robot);
  return new Promise((done) => {
    robot.adapter.on('connected', () => {
      const user = robot.brain.userForId('1', { name: 'alice', room: '#testroom' });
      done(new TestBotContext(robot, user));
    });
    robot.run();
  });
}

module.exports = { createTestBot, TestBotContext };
