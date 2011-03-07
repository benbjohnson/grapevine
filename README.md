Grapevine - Message Aggregator
==============================

## DESCRIPTION

Grapevine is a server for loading messages from various sources, aggregating and
trending messages into topics, and then sending notifications for trending
topics to Twitter.

Grapevine follows the rules of [Semantic Versioning](http://semver.org/).


## RUNNING

To install Grapevine, simply install the gem:

	$ [sudo] gem install grapevine

Then run the `grapevine` command to manage your server.

	$ grapevine start
	$ grapevine stop
	$ grapevine restart

Grapevine also comes with a command line interface to find more information on
your messages and topics. The following commands are available:

	$ grapevine load
	$ grapevine notify
	$ grapevine show messages
	$ grapevine show notifiers
	$ grapevine show notifier [NAME]
	$ grapevine show sources
	$ grapevine show tags
	$ grapevine show topics
	$ grapevine show topic [NAME]

For more information on each command, you can view the inline help:

	$ grapevine help [COMMAND]


## SOURCES & NOTIFIERS

Grapevine has a pluggable architecture that allows any message sources to be
matched up with any set of topic notification mechanisms.

Currently Grapevine supports the following sources:

* `twitter-trackback` - Retrieves tweets for a given site.
* `twitter-github` - Retrieves tweets associated with GitHub projects. Allows
  filtering of projects based on programming language.

And the following notification mechanisms are available:

* `twitter` - Tweets a message to a specified account for the most popular
  aggregated topic at the moment. Frequency of tweets and windowing options can
  be specified.


## CONFIGURATION

Sources, notification mechanisms and other options can be specified in the
`~/grapevine.yml` file. Global configuration options for the Bit.ly API key and
Twitter API consumer keys are listed at the top.

The following is an example configuration file:

	bitly_username: johndoe
	bitly_api_key: R_ae81e4e8ef7d10728725a57e90e1933

	twitter_consumer_key: YpHAA9xFYruS06yk2Jvxy
	twitter_consumer_secret: aMYXpyl4Sa89xx4YD5UwftkveuSfjtoDZlarJHR1ZHH

	sources:
	  - name: my_github_source
	    type:  twitter-github
	    frequency: 1h

	notifiers:
	  - name: github_js
	    type: twitter
	    username: github_js
	    oauth_token: 1023929394-M8wtmerAMnI7ndH9x0ADzHTOWOD0sxx9UsjvgcxNNx
	    oauth_token_secret: m6Ryi8h7Y6yBxa0x0ffsaWUybE2vrxx8a9sYFnDB9QFG
	    source: my_github_source
	    frequency: 1h30m
	    window: 6M
	    tags: [language:javascript]
	
	  - name: github_rb
	    type: twitter
	    username: github_rb
	    oauth_token: 310128260-VKGv2UDYMNF0x0A0fsfqZh3QwxiMkd0xfa0sf3vv
	    oauth_token_secret: GAfa9xk6wyQ98mjXmXfrPN0as00zxkStjxdzwTlEt
	    source: my_github_source
	    frequency: 2h
	    window: 8M
	    tags: [language:ruby]

This configuration file sets up a single source to retrieve messages from
Twitter that mention GitHub projects. It then sets up two notifiers to send out
trending topics pulled from `my_github_source` that are tagged with the
`javascript` and `ruby` languages, respectively. The Twitter authorization is
specified for each notifier with the `username`, `oauth_token` and
`oauth_token_secret` settings.

The `frequency` property sets how often topics will be sent out. In this example
the `github_js` Twitter account will send out every hour and a half while the
`github_rb` Twitter account will send out every two hours. The `window` property
specifies how long until a trending topic can be mentioned again. In this
example, topics can be mentioned again six months after their last mention.

The `frequency` and `window` properties are time periods that can be defined
in a short hand. The following are the available time periods:

* `y` - Years
* `M` - Months
* `w` - Weeks
* `d` - Days
* `h` - Hours
* `m` - Minutes
* `s` - Seconds


## TWITTER AUTHORIZATION

OAuth is not an easy process for people who are not familiar with it. Luckily,
there is [Authoritarian](https://github.com/benbjohnson/authoritarian).

To start, register your Twitter application here:

[Twitter Developers](http://dev.twitter.com/)

Then install Authoritarian and add your application:

	$ gem install authoritarian
	$ authoritarian add application
	# Follow the prompts

You can find your Consumer Key and Consumer Secret on your Twitter application's
page at the Twitter Developers site mentioned above.

Next add the Twitter users you want to authorize:

	$ authoritarian add user
	# Input your username and password

Once you've added all your users, you can find the OAuth token and token secrets
by listing all your users:

	$ authoritarian show users --all

Simple copy the consumer token and secret to your Grapevine configuration.


## CONTRIBUTE

If you'd like to contribute to Grapevine, start by forking the repository
on GitHub:

http://github.com/benbjohnson/grapevine

Then follow these steps to send your changes:

1. Clone down your fork
1. Create a topic branch to contain your change
1. Code
1. All code must have MiniTest::Unit test coverage.
1. If you are adding new functionality, document it in the README
1. If necessary, rebase your commits into logical chunks, without errors
1. Push the branch up to GitHub
1. Send me a pull request for your branch