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
      
      def from_array_hash( data )
        if filter.root
          data.collect{ |d| @model_class.new( filter.filter( d[ filter.root ] ) ) }
        else
          data.collect{ |d| @model_class.new( filter.filter( d ) ) }
        end
      end
      private :from_array_hash

      def from_hash(data, options = nil)
        filter.use( options ) if options
        if data.is_a? Array
          from_array_hash( data )
        else
          data = data[ filter.root ] if filter.root
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
