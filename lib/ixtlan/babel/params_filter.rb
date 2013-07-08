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

      class FilterResult

        def initialize( model, params, keeps )
          @model = model
          @data = keeps
          @data[ :params ] = params
        end

        def new_model
          @model.send( :new, params )
        end

        def params
          @data[ :params ]
        end

        def method_missing( method, *args )
          if respond_to?( method )
            @data[ method ] || @data[ method.to_s ]
          elsif @data.respond_to?( method )
            @data.send( method, *args )
          else
            super
          end
        end

        def respond_to?( method )
          @data.key?( method ) || @data.key?( method.to_s )
        end
      end

      def filter_it( data )
        filter.options = self.class.config.single_options( @context_or_options )
        data = data.dup
        data = data[ filter.options[ :root ] ] if filter.options[ :root ]
        keeps = {}
        ( filter.options[ :keep ] || [] ).each do |k|
          keep = data[ k.to_s ] || data[ k.to_sym ]
          keeps[ k.to_s ] = data.delete( k.to_s ) ||
            data.delete( k.to_sym ) unless keep.is_a? Hash
        end
        filtered_data = filter.filter( data )
        ( filter.options[ :keep ] || [] ).each do |k|
          keeps[ k.to_s ] = filtered_data.delete( k.to_s ) ||
            filtered_data.delete( k.to_sym ) unless keeps.member?( k.to_s )
        end
        FilterResult.new( @model_class, filtered_data, keeps )
      end
    end
  end
end
