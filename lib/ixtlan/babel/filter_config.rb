require 'ixtlan/babel/context'
module Ixtlan
  module Babel
    class FilterConfig

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

      def single_options
        @options || context[default_context_key[0]] || {}
      end

      def collection_options
        @options || context[default_context_key[1]] || {}
      end

      attr_accessor :root
      def root
        @root ||= single_options.key?(:root) ? single_options[:root].to_s : nil
      end

      private

      def options_for( data )
        @options || (data.is_a?(Array) ? collection_options : single_options)
      end

      def serialize( data )
        if @map && ser = @map[ data.class.to_s ]
          ser.call(data)
        else
          data
        end
      end

    end
  end
end
