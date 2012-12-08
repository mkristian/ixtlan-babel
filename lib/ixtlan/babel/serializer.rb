require 'ixtlan/babel/hash_filter'
require 'ixtlan/babel/model_filter'
require 'ixtlan/babel/filter_config'
module Ixtlan
  module Babel
    class Serializer

      def id
        if @model_or_models.is_a? Array
          super
        else
          @model_or_models.id
        end
      end

      def initialize(model_or_models)
        @model_or_models = model_or_models
      end
      
      def respond_to?(method)
        @model_or_models.respond_to?(method)
      end

      def method_missing(method, *args, &block)
        @model_or_models.send(method, *args, &block)
      end
      
      def add_custom_serializers(map)
        filter.add_custom_serializers(map)
      end

      private

      def self.config
        @config ||= FilterConfig.new
      end

      def filter
        @filter ||= @model_or_models.is_a?( Hash ) ? HashFilter.new :  ModelFilter.new
      end

      protected

      # for rails
      def self.model(model = nil)
        @model_class = model if model
        @model_class ||= self.to_s.sub(/Serializer$/, '').constantize
      end

      # for rails
      def self.model_name
        model.model_name
      end

      def self.default_context_key(single = :single, collection = :collection)
        config.default_context_key(single, collection)
      end

      def self.add_context(key, options = {})
        config[key] = options
      end

      public

      def use( context_or_options )
        @context_or_options = context_or_options
        self
      end

      def to_hash(options = nil)
        setup_filter( options )
        if collection?
           @model_or_models.collect do |m|
            filter_model( m )
          end
        else
          filter_model( @model_or_models )
        end
      end

      def to_json(options = nil)
        to_hash(options).to_json
      end

      def setup_filter(options)
        o = if collection?
              self.class.config.collection_options( @context_or_options )
            else
              self.class.config.single_options( @context_or_options )
            end
        filter.options = o.merge!( options || {} )
      end
      private :setup_filter

      def collection?
        @is_collection ||= @model_or_models.respond_to?(:collect) && ! @model_or_models.is_a?(Hash)
      end
      private :collection?

      def to_xml(options = nil)
        setup_filter

        result = to_hash

        root = filter.root

        if root && result.is_a?(Array) && root.respond_to?(:pluralize)
          root = root.pluralize
        end
        result.to_xml :root => root
      end

      def to_yaml(options = nil)
        to_hash(options).to_yaml
      end
      
      protected

      def attr(model)
        model.attributes if model
      end

      private

      def filter_model( model )
        if root = self.class.config.root
          {root.to_s => filter.filter( model ){ |model| attr(model) } }
        else
          filter.filter( model ){ |model| attr(model) }
        end
      end 
    end
  end
end
