module Ixtlan
  module Babel
    
    module ModelSerializer

      attr_reader :model

      def self.included( model )
        model.extend( ClassMethods )
      end

      def respond_to? name
        @model.respond_to? name
      end

      def method_missing( name, *args, &block )
        @model.send( name, *args, &block )
      end

      def to_json
        to_data.to_json
      end
      
      def to_yaml
        to_data.to_yaml
      end

      def to_data
        if @model.respond_to?( :collect ) and not @model.is_a?( Hash )
          @model.collect do |m|
            replace( m ).to_hash
          end
        else
          to_hash
        end
      end

      def serializers=( map )
        @map = map
      end

      def serialize( data )
        if @map && ser = @map[ data.class.to_s ]
          ser.call(data)
        else
          data
        end
      end

      def to_hash
        result = {}
        self.class.attributes.each do |k,v|
          if v
            filter = v.is_a?( Array ) ? v[ 0 ] : v
            filter.serializers = @map
            model = @model.send( k )
            result[ k ] = filter.replace( model ).to_data if model
          else
            result[ k ] = serialize( @model.send( k ) )
          end
        end
        result
      end
      
      def initialize( model = nil, map = nil )
        super()
        @map = map
        replace( model )
      end

      def replace( model )
        @model = model
        self
      end

      module ClassMethods

        def attribute( name, type = nil )
          attributes[ name.to_sym ] = new_instance( type )
        end

        def attributes( *args )
          if args.size == 0
            @attributes ||= (superclass.attributes.dup rescue nil) || {}
          else
            args.each { |a| attribute( a ) }
          end
        end
        
        def new_instance( type )
          case type
          when Array
            [ type[ 0 ].new ]
          when NilClass
            nil
          else
            type.new
          end
        end
      end
    end
  end
end
