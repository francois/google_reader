require "time"

module GoogleReader
  class Feed
    attr_reader :feed

    def initialize(feed)
      @feed = feed
    end

    def entries
      @entries ||= @feed.search("entry").map {|entry| Entry.new(entry)}
    end

    def id
      @feed.search("id").first.text
    end

    def updated_at
      Time.parse( @feed.search("updated").first.text )
    end

    def continuation
      @feed.search("gr:continuation", "gr" => GoogleReader::GOOGLE_ATOM_NAMESPACE).first.text
    end

    def title
      @feed.search("title").first.text
    end

    def href
      @feed.search("link[rel=self]").first["href"]
    end

    def author
      @feed.search("author name").first.text
    end
  end
end
