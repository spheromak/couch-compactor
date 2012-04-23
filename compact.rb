#!/bin/env ruby
require 'net/http'
require 'json'

if ARGV.nil? or ARGV.empty? 
  puts "Must at least specify a default DB to use"
  exit 1
end

database = ARGV.shift
servers = ARGV
if servers.empty?
 servers = ['localhost:5984']
end


module Couch
  class Server
    def initialize(host, port = 5984, options = nil)
      @host = host
      @port = port
      if host.match(/(.+):(\d+)/)
        @host = $1
        @port = $2
      end
      @options = options
    end

    def delete(uri)
      request(Net::HTTP::Delete.new(uri))
    end

    def get(uri)
      request(Net::HTTP::Get.new(uri))
    end

    def put(uri, json="")
      req = Net::HTTP::Put.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def post(uri, json="")
      req = Net::HTTP::Post.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def request(req)
      res = Net::HTTP.start(@host, @port) { |http|http.request(req) }
      unless res.kind_of?(Net::HTTPSuccess)
        handle_error(req, res)
      end
      res
    end

    private

    def handle_error(req, res)
      e = RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
      raise e
    end
  end
end

def get_views(database)
  views = []
  query = "/#{database}"
  query << '/_all_docs?startkey="_design/"&endkey="_design0"&include_docs=true'
  res = @server.get(query)
  JSON.parse(res.body)["rows"].each do |row|
    views  << row["id"].gsub(/_design\//,"") 
  end
  views
end

servers.each do |server|
  @server = Couch::Server.new(server)
  get_views(database).each do |view|
    puts "compacting view #{view}"
    @server.post "/#{database}/_compact/#{view}"
  end
  @server.post "/#{database}/_compact"
  @server.post "/#{database}/_view_cleanup"
end

