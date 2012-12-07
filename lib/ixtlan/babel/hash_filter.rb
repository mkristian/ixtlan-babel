require 'ixtlan/babel/config'
module Ixtlan
  module Babel
    class HashFilter

      def initialize(context_or_options = nil)
        use(context_or_options)
      end
      
      private

      def context
        @context ||= {}
      end

      public

      def add_custom_serializers( map )
        @map = map
      end

      def default_context_key( single = :single, 
                               collection = :collection )
        @single, @collection = single, collection
      end

      def []=( key, options )
        context[ key.to_sym ] = options if key
      end

      def []( key )
        context[ key.to_sym ] if key
      end

      def use( context_or_options )
        if context_or_options
          case context_or_options
          when Symbol  
            if opts = context[ context_or_options ]
              @options = opts.dup
            end
          when Hash
            @options = context_or_options
          end
        else
          @options = nil
        end
        self
      end

      def filter( hash = {} )
        if hash
          filter_data( hash, 
                       Config.new( options_for( hash ) ) ) 
        end
      end
        
      def single_options
        @options || context[default_context_key[0]] || {}
      end

      def collection_options
        @options || context[default_context_key[1]] || {}
      end

      def root
        @root ||= single_options.key?(:root) ? single_options[:root].to_s : nil
      end

      private

      def options_for( hash )
        @options || (hash.is_a?(Array) ? collection_options : single_options)
      end

      def filter_array( array, options )
        array.collect do |item| 
          if item.is_a?( Array ) || item.is_a?( Hash )
            filter_data( item, options )
          else
            item
          end
        end
      end

      def serialize( data )
        if @map && ser = @map[ data.class.to_s ]
          ser.call(data)
        else
          data
        end
      end
      
      def filter_data( data, config )
        result = {}
        data.each do |k,v|
          k = k.to_s
          case v
          when Hash
            result[ k ] = filter_data( v, config[ k ] ) if config.include?( k )
          when Array
            result[ k ] = filter_array( v, config[ k ] ) if config.include?( k )
          else
            result[ k ] = serialize( v ) if config.allowed?( k )
          end
        end
        result
      end
    end
  end
end
