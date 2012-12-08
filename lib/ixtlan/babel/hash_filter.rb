require 'ixtlan/babel/abstract_filter'
module Ixtlan
  module Babel
    class HashFilter < AbstractFilter

      def filter( data )
        if data
          filter_data( data, 
                       Context.new( options ) )
        end
      end

      private

      def filter_array( array, options )
        array.collect do |item| 
          if item.is_a?( Array ) || item.is_a?( Hash )
            filter_data( item, options )
          else
            item
          end
        end
      end

      def filter_data( data, context )
        result = {}
        data.each do |k,v|
          k = k.to_s
          case v
          when Hash
            result[ k ] = filter_data( v, context[ k ] ) if context.include?( k )
          when Array
            result[ k ] = filter_array( v, context[ k ] ) if context.include?( k )
          else
            result[ k ] = serialize( v ) if context.allowed?( k )
          end
        end
        result
      end
    end
  end
end
