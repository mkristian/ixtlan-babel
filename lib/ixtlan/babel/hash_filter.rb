#
# Copyright (C) 2013 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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
            serialize( item )
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
