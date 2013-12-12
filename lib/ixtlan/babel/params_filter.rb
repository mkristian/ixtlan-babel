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

      def self.add_context( key = :single, options = nil, &block )
        current = config[key] = options || { :only => [] }
        @context = key
        yield if block
        current[ :keep ] = @keep if @keep
        current.merge!( @allow ) if @allow
        current[ :root ] = @root
      ensure
        @context = nil
	@allow = nil
	@keep = nil
        @root = nil
      end

      def self.root( root )
        if @context
          @root = root
        else
          config.root = root
        end
      end

      def self.keep( *args )
        @keep = *args
      end

      def self.only( *args )
        result = {}
        if args.last.is_a? Hash
          result[ :include ] = args.last
          result[ :only ] = args[ 0..-2 ]
        else
          result[ :only ] = args
        end
        @allow = result
        result
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

        def []( key )
           params[ key ]
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
        opts = ( filter.options[ :keep ] || [] ).collect { |k| k.to_s }
        opts.each do |k|
          keep = data[ k ] || data[ k.to_sym ] 
          unless keep.is_a? Hash
            keeps[ k ] = data.delete( k ) || data.delete( k.to_sym )
          end
        end
        filtered = filter.filter( data )
        opts.each do |k| 
          unless keeps.member?( k )
            keeps[ k ] = filtered.delete( k ) || filtered.delete( k.to_sym )
          end
          # just make sure we have an entry for each keeps key
          keeps[ k ] ||= nil
        end
        FilterResult.new( @model_class, filtered, keeps )
      end
    end
  end
end
