module Ixtlan
  module Babel
    class Deserializer

      def initialize(model_class)
        @model_class = model_class
      end

      private

      def self.config
        @config ||= FilterConfig.new
      end

      def filter
        @filter ||= HashFilter.new
      end

      protected

      def self.default_context_key(default)
        config.default_context_key(default)
      end

      def self.add_context(key, options = {})
        config[key] = options
      end

      public

      def use(context_or_options)
        @context_or_options = context_or_options
        self
      end
      
      def from_array_hash( data )
        if filter.options[:root]
          data.collect{ |d| @model_class.new( filter.filter( d[ filter.options[:root] ] ) ) }
        else
          data.collect{ |d| @model_class.new( filter.filter( d ) ) }
        end
      end
      private :from_array_hash

      def from_hash(data, options = nil)
        filter.options = options || {}
        filter.options[:root] ||= self.class.config.root
        if data.is_a? Array
          from_array_hash( data )
        else
          data = data[ filter.options[:root] ] if filter.options[:root]
          @model_class.new( filter.filter( data ) )
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
