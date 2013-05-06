Redis server in Ruby

Install
=======

You can start it up with `./bin/rbedis --conf /path/to/config.rb`

This is not on Rubygems yet.

Usage
=====

This is a basic Redis server built in Ruby (with Eventmachine). It supports basic key and server commands ([Redis Commands](http://redis.io/commands#generic)). 

It doesn't support hashes, lists, sets, sorted sets, pub sub, transactions and scripting.

The database is named `database.rbedis`, and it's created the first time you run it. The config file is `config.rb`.

**This is obviously not ready for production.**

The parser and command definitions surely could be better designed, but the current implementation works.

You can easily implement other datastores by just looking at the `datastore.rb` file. Current one saves the database hash to a file using Marshal.

This implementation works with the default `redis-rb` client.

The default Redis password is `test`.

Author
======

[Pablo Merino](http://pmerino.me)

pablo@wearemocha.com

License: MIT
