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
module Ixtlan
  module Babel
    class Context

      def initialize( options )
        @only = options[ :only ].collect { |o| o.to_s } if options[ :only ]
        @except = ( options[:except] || [] ).collect { |e| e.to_s }

        opts = options[ :include ]
        @include = case opts
                   when Array
                     opts.collect { |i| i.to_s }
                   when Hash
                     Hash[ opts.collect { |k,v| [ k.to_s, v ] } ]
                   else
                     []
                   end
        @methods = (options[:methods] || []).collect { |m| m.to_s }
      end

      def methods
        @methods + ( @include.is_a?( Array ) ? @include : @include.keys ) 
      end

      def allowed?( key )
        ( @only && @only.include?( key ) ) || ( @only.nil? && !@except.include?( key ) ) || @methods.include?( key )
      end

      def include?( key )
        @include.include?( key ) || @methods.include?( key ) 
      end

      def array?
        @include.is_a?( Array )
      end

      def []( key )
        self.class.new( @include.is_a?( Array ) ? {} : @include[ key ] )
      end

    end
  end
end
