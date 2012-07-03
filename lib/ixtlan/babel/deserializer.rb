module Ixtlan
  module Babel
    class Deserializer

      def initialize(model_class)
        @model_class = model_class
      end

      private

      def self.filter
        @filter ||= HashFilter.new
      end

      def filter
        @filter ||= self.class.filter.dup
      end

      protected

      def self.default_context_key(default)
        filter.default_context_key(default)
      end

      def self.add_context(key, options = {})
        filter[key] = options
      end

      public

      def use(context_or_options)
        filter.use(context_or_options)
        self
      end

      def from_hash(data, options = nil)
        filter.use(options) if options
        if root = filter.options[:root]
          if data.is_a? Array
            root = root.to_s
            data.collect{ |d| @model_class.new(filter.filter(d[root])) }
          else
            @model_class.new(filter.filter(data[root.to_s]))
          end
        else
          if data.is_a? Array
            data.collect{ |d| @model_class.new(filter.filter(d)) }
          else
            @model_class.new(filter.filter(data))
          end
        end
      end

      def from_json(json, options = nil)
        data = JSON.parse(json)
        from_hash(data, options)
      end
      
      def from_yaml(yaml, options = nil)
        data = YAML.load_stream(StringIO.new(yaml)).documents
        from_hash(data, options)
      end
    end
  end
end
