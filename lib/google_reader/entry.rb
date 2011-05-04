require "ostruct"
require "time"

module GoogleReader
  class Entry
    def initialize(entry)
      @entry = entry
    end

    def id
      id_node.text
    end

    def original_id
      oid_node = id_node.attribute_with_ns("original-id", GOOGLE_ATOM_NAMESPACE)
      return self.id if oid_node.nil?

      # Cater to JRuby + libffi
      return self.id if oid_node.respond_to?(:null?) && oid_node.null?
      oid_node.text
    end

    def title
      unhtml(@entry.search("title").first.text)
    end

    def categories
      @entry.search("category").reject do |node|
        node["scheme"] == "http://www.google.com/reader/"
      end.map do |node|
        node["label"] || node["term"]
      end
    end

    def summary
      node = @entry.search("summary")
      return nil unless node
      return nil if node.respond_to?(:null?) && node.null?
      node.text
    end

    def published_at
      Time.parse(@entry.search("published").first.text)
    end

    def updated_at
      node = @entry.search("updated").first
      node ? Time.parse(@entry.search("updated").first.text) : published_at
    end

    def href
      @entry.search("link[rel=alternate]").reject do |node|
        node["href"].to_s.empty?
      end.detect do |node|
        node["type"] == "text/html"
      end["href"]
    end

    def has_known_author?
      node = @entry.search("author").first
      return false unless node
      attr = node.attribute_with_ns("unknown-author", GOOGLE_ATOM_NAMESPACE)
      return true unless attr

      # Cater to JRuby + libffi
      return true if attr.respond_to?(:null?) && attr.null?
      attr.text != "true"
    end

    def author
      @entry.search("author name").first.text
    end

    def source
      node = @entry.search("source").first
      Source.new(:title     => unhtml(node.search("title").first.text),
                 :href      => node.search("link[rel=alternate]").first["href"],
                 :id        => node.search("id").first.text,
                 :stream_id => node.attribute_with_ns("stream-id", GOOGLE_ATOM_NAMESPACE).text)
    end

    def liking_users
      # NOTE: CSS namespaces don't work all that well: must use XPath here
      @entry.search("./gr:likingUser", "gr" => GOOGLE_ATOM_NAMESPACE).map do |node|
        node.text
      end
    end

    def id_node
      nodes = @entry.search("id")
      return nil if nodes.empty?
      nodes.first
    end

    def unhtml(text)
      text.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&").gsub("&quot;", '"')
    end

    GOOGLE_ATOM_NAMESPACE = "http://www.google.com/schemas/reader/atom/".freeze
  end
end
