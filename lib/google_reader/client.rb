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

    def logger=(value)
      RestClient.log = value
    end

    BASE_URL = "http://www.google.com/reader/atom/user/-/".freeze
    STATE_URL = BASE_URL + "state/com.google/".freeze

    %w(
      read
      fresh
      broadcast
      starred
      reading-list
      subscriptions
      tracking-emailed
      tracking-item-link-used
      tracking-body-link-used).each do |suffix|

      method_name = suffix.gsub("-", "_") + "_feed"
      define_method(method_name) do |*args|
        str_params = options_to_query_string( args.first || Hash.new )
        content = RestClient.get(STATE_URL + suffix + "?#{str_params}", headers)
        Feed.new( Nokogiri::XML(content) )
      end

      method_name = suffix.gsub("-", "_") + "_items"
      define_method(method_name) do |*args|
        __send__(method_name.sub("_items", "_feed"), *args).entries
      end
    end

    def unread_items(options={})
      reading_list_feed(options)
    end

    private

    def options_to_query_string(options)
      params = Hash.new
      params[:n] = options[:count] || 20
      params[:xt] = options.fetch(:exclude) if options.has_key?(:exclude)

      if options.has_key?(:since) then
        params[:r]  = "o"
        params[:ot] = options[:since].to_i
      end

      params.map do |k, v|
        CGI.escape(k.to_s) << "=" << CGI.escape(v.to_s)
      end.join("&")
    end
  end
end
