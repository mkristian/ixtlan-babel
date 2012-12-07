module Ixtlan
  module Babel
    class Config

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
      end

      def allowed?( key )
        ( @only && @only.include?( key ) ) || ( @only.nil? && !@except.include?( key ) )
      end

      def include?( key )
        @include.include? key
      end

      def []( key )
        self.class.new( @include.is_a?( Array ) ? {} : @include[ key ] )
      end

    end
  end
end
