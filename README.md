couch-compactor
===============
Simple Compactor ruby script that queries couch for views 
compacts the DB and Views

Requirements 
============ 
Needs ruby json lib so it can talk to couchdb


Usage
=====
Basic usage
```shell ./compact.rb mydb  ```
by default it uses localhost:5984 as the server

You can specify a list of servers
```shell ./compact.rb mydb  server1 server2 ```

You can specify a servers and ports by default the port is 5984
```shell ./compact.rb mydb  server1:1337  server2 ```





