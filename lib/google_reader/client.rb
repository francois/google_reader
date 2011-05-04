require "rest_client"
require "nokogiri"
require "cgi"

module GoogleReader
  class Client
    def self.authenticate(*args)
      case args.length
      when 1
        authenticate_using_token(args.first)
      when 2
        authenticate_using_username_and_password(args.first, args.last)
      else
        raise ArgumentError, "Expected either token, or username and password, received #{args.inspect}"
      end
    end

    def self.authenticate_using_token(token)
      new(token)
    end

    def self.authenticate_using_username_and_password(username, password)
      resp = RestClient.post("https://www.google.com/accounts/ClientLogin",
                             :Email   => username,
                             :Passwd  => password,
                             :service => "reader")

      dict = resp.split.inject(Hash.new) do |memo, encoded_pair|
        key, value = encoded_pair.split("=").map {|val| CGI.unescape(val)}
        memo[key] = value
        memo
      end

      token = dict["Auth"]
      new(token)
    end

    attr_reader :token, :headers

    def initialize(token)
      @token   = token
      @headers = {"Authorization" => "GoogleLogin auth=#{token}", "Accept" => "application/xml"}
    end

    BASE_URL = "http://www.google.com/reader/atom/user/-/".freeze
    STATE_URL = BASE_URL + "state/com.google/".freeze

    %w(
      read
      broadcast
      starred
      subscriptions
      tracking-emailed
      tracking-item-link-used
      tracking-body-link-used).each do |suffix|

      method_name = suffix.gsub("-", "_") + "_items"
      define_method(method_name) do |*args|
        count = args.first || 20
        content = RestClient.get(STATE_URL + suffix + "?n=#{CGI.escape(count.to_s)}", headers)
        parse_atom_feed(content)
      end
    end

    def unread_items
      content = RestClient.get(STATE_URL + suffix + "?n=#{CGI.escape(count.to_s)}&xt=#{CGI.escape("state/com.google/read")}", headers)
      parse_atom_feed(content)
    end

    def parse_atom_feed(feed)
      doc = Nokogiri::XML(feed)
      doc.search("entry").map {|entry| Entry.new(entry)}
    end
  end
end
