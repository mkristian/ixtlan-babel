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
    class ModelFilter < AbstractFilter

      def filter( model, &block )
        if model
          data = block.call( model )
          filter_data( model, data,
                       Context.new( options ),
                       &block ) 
        end
      end

      private

      def filter_array( models, options, &block )
        models.collect do |i|
          if i.respond_to? :attributes
            filter_data(i, block.call(i), options, &block)
          else
            i
          end
        end
      end

      def setup_data(model, data, context)
        context.methods.each do |m|
          unless data.include?(m)
            data[ m ] = model.send( m.to_sym )
          end
        end
      end

      def filter_data(model, data, context, &block)
        setup_data(model, data, context)
        
        result = {}
        data.each do |k,v|
          k = k.to_s
          if v.respond_to? :attributes
            result[ k ] = filter_data( v, block.call(v), context[ k ], &block ) if context.include?( k )
          elsif v.is_a? Array
            result[ k ] = filter_array( v, context[ k ], &block ) if context.include?( k )
          else
            result[ k ] = serialize( v ) if context.allowed?( k ) && ! v.respond_to?( :attributes )
          end
        end
        result
      end
    end
  end
end