require "rest_client"
require "nokogiri"
require "cgi"

module GoogleReader
  class Client
    def self.authenticate(username, password)
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
      new("Authorization" => "GoogleLogin auth=#{token}", "Accept" => "application/xml")
    end

    attr_reader :headers

    def initialize(headers)
      @headers = headers
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
      define_method(method_name) do |count=20|
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
