module GoogleReader
  class Source
    attr_reader :id, :name, :href, :title

    def initialize(values)
      %w(title href id stream_id).each do |attr|
        instance_variable_set("@#{attr}", values.fetch(attr.to_sym))
      end
    end
  end
end
