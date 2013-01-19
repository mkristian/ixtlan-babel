require 'ixtlan/babel/hash_filter'
require 'ixtlan/babel/filter_config'

module Ixtlan
  module Babel
    class ParamsFilter

      def initialize( model_class )
        @model_class = model_class
      end

      private

      def self.config
        @config ||= FilterConfig.new
      end

      def filter
        @filter ||= HashFilter.new
      end

      protected

      def self.default_context_key(default)
        config.default_context_key(default)
      end

      def self.add_context(key, options = {})
        config[key] = options
      end

      def self.root( root )
        config.root = root
      end

      public

      def use(context_or_options)
        @context_or_options = context_or_options
        self
      end
      def filter_it( data )
        filter.options = self.class.config.single_options( @context_or_options )
        data = data[ filter.options[ :root ] ] if filter.options[ :root ]
        keeps = {}
        ( filter.options[ :keep ] || [] ).each do |k|
          keeps[ k.to_s ] = data[ k.to_s ] || data[ k.to_sym ]
        end
        [ filter.filter( data ), keeps ]
      end

      def new( data )
        @model_class.new( filter( data ) )
      end
    end
  end
end
