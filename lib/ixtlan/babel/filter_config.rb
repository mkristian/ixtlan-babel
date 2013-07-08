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
        context_options( context_or_options ) ||
          context[ default_context_key[ 0 ] ] || {}
      end

      def collection_options( context_or_options )
        context_options( context_or_options ) ||
          context[ default_context_key[ 1 ] ] || {}
      end

      attr_accessor :root

    end
  end
end
