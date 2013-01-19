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
    class Deserializer

      def initialize(model_class)
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

      public

      def use(context_or_options)
        @context_or_options = context_or_options
        self
      end
      
      def from_array_hash( data )
        if filter.options[:root]
          data.collect{ |d| @model_class.new( filter.filter( d[ filter.options[:root] ] ) ) }
        else
          data.collect{ |d| @model_class.new( filter.filter( d ) ) }
        end
      end
      private :from_array_hash

      def from_hash(data, options = nil)
        filter.options = options || {}
        filter.options[:root] ||= self.class.config.root
        if data.is_a? Array
          from_array_hash( data )
        else
          data = data[ filter.options[:root] ] if filter.options[:root]
          @model_class.new( filter.filter( data ) )
        end
      end

      def from_json(json, options = nil)
        data = JSON.parse(json)
        from_hash(data, options)
      end
      
      def from_yaml(yaml, options = nil)
        data = YAML.load_stream(StringIO.new(yaml)).documents
        from_hash(data, options)
      end
    end
  end
end