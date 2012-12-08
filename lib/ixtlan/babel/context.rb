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
        @include.include? key
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
