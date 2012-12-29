require 'ixtlan/babel/context'
module Ixtlan
  module Babel
    class FilterConfig
      
      private

      def context
        @context ||= {}
      end

      def context_options( context_or_options )
        if context_or_options
          case context_or_options
          when Symbol  
            if opts = context[ context_or_options ]
              opts.dup
            end
          when Hash
            context_or_options
          end
        end
      end

      public

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

      def single_options( context_or_options )
        context_options( context_or_options ) || (context[default_context_key[0]]) || {}
      end

      def collection_options( context_or_options )
        context_options( context_or_options ) || (context[default_context_key[1]]) || {}
      end

      attr_accessor :root

    end
  end
end
