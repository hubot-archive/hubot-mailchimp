Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'
fs = require 'fs'

expect = chai.expect

helper = new Helper('../src/mailchimp.coffee')

describe 'mailchimp basic operations', ->
  beforeEach ->
    process.env.MAILCHIMP_API_KEY = 'foo123bar456baz-us'
    process.env.MAILCHIMP_LIST_ID = '123foo456'

    @room = helper.createRoom()

    do nock.disableNetConnect

    nock('https://us.api.mailchimp.com')
      .get("/3.0/campaigns?start=0&limit=1&status=sent")
      .reply 200, fs.readFileSync('test/fixtures/campaigns.json')

    nock('https://us.api.mailchimp.com')
      .post("/3.0/lists/123foo456/members")
      .reply 200, fs.readFileSync('test/fixtures/subscriber-subscribed.json')
    
    nock('https://us.api.mailchimp.com')
      .delete("/3.0/lists/123foo456/members/fd876f8cd6a58277fc664d47ea10ad19")
      .reply 204

  afterEach ->
    @room.destroy()

  # Test case
  it 'returns campaign statistics', () ->
    selfRoom = @room
    testPromise = new Promise (resolve, reject) ->
      selfRoom.user.say('alice', '@hubot mailchimp')
      setTimeout(() ->
        resolve()
      , 1000)

    testPromise.then (result) ->
      expect(selfRoom.messages).to.eql [
        ['alice', '@hubot mailchimp']
        ['hubot', "Last campaign \"Poll test\" was sent to 1 subscribers (1 opened, 0 clicked)"]
      ]
  
  it 'subscribes a user', () ->
    selfRoom = @room
    testPromise = new Promise (resolve, reject) ->
      selfRoom.user.say('alice', '@hubot subscribe johndoe@example.com')
      setTimeout(() ->
        resolve()
      , 1000)
  
    testPromise.then (result) ->
      expect(selfRoom.messages).to.eql [
        ['alice', '@hubot subscribe johndoe@example.com']
        ['hubot', "@alice Attempting to subscribe johndoe@example.com..."]
        ['hubot', "You successfully subscribed johndoe@example.com."]
      ]
  
  it 'unsubscribes a user', () ->
    selfRoom = @room
    testPromise = new Promise (resolve, reject) ->
      selfRoom.user.say('alice', '@hubot unsubscribe johndoe@example.com')
      setTimeout(() ->
        resolve()
      , 1000)
  
    testPromise.then (result) ->
      expect(selfRoom.messages).to.eql [
        ['alice', '@hubot unsubscribe johndoe@example.com']
        ['hubot', "@alice Attempting to unsubscribe johndoe@example.com..."]
        ['hubot', "You successfully unsubscribed johndoe@example.com."]
      ]
