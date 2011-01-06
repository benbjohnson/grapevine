Grapevine - Message Aggregator
==============================

## DESCRIPTION

Grapevine is a server for loading social media from various sources, aggregating
it and sending the results to a Twitter account, RSS or e-mail.

Grapevine follows the rules of [Semantic Versioning](http://semver.org/).


## RUNNING

To install Grapevine, simply install the gem:

	$ [sudo] gem install grapevine

Then run the `grapevine` command to manage your server.

	$ grapevine start
	$ grapevine stop
	$ grapevine restart


## SOURCES & NOTIFIERS

Grapevine has a pluggable architecture that allows any media sources to be
matched up with any set of notification mechanisms.

Currently Grapevine supports the following sources:

* `twitter-github` - Retrieves tweets associated with GitHub projects. Allows
  filtering of projects based on programming language.

And the following notification mechanisms are available:

* `twitter` - Tweets a message to a specified account for the most popular
  aggregated topic at the moment. Frequency of tweets and windowing options can
  be specified.


## CONFIGURATION

Sources, notification mechanisms and other options can be specified in the
`/etc/grapevine/config.yml` file or can be passed in using the `--config`
option.

The following is an example configuration file:

	sources:
	  - type:  twitter-github
	    frequency: 1h

	notifiers:
	  - type: twitter
	    username: ghtrends_js
	    api_key: xyz
	    source: twitter-github
	    frequency: 8h
	    window: 1w
	    tags: [language:javascript]

This file sets up a source to retrieve GitHub projects mentioned on Twitter.
Then a notifier is setup to send a tweet for the most popular project that uses
the JavaScript language every 8 hours. Once a notification has been made, it
cannot be made again within the time period specified by the window (1 week).


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