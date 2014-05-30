module Ixtlan
  module Babel
    
    module HashFilter

      def self.included( model )
        model.extend( ClassMethods )
      end

      def filter( data )
        @attributes = do_filter( data, self.class.attributes )
      end

      def hidden( data )
        @hidden = do_filter( data, self.class.hiddens )
      end

      def attributes
        @attributes
      end
      alias :params :attributes

      def respond_to? name
        key = name.to_sym
        self.class.hiddens.key?( key ) || self.class.attributes.key?( key ) || super
      end

      def method_missing( name, *args )
        key = name.to_sym
        if self.class.hiddens.key?( key )
          to_attribute( key, 
                        @hidden[ key ] || @hidden[ key.to_s ], 
                        self.class.hiddens )
        elsif self.class.attributes.key?( key )
          to_attribute( key,
                        @attributes[ key ] || @attributes[ key.to_s ],
                        self.class.attributes )      
        else
          super
        end
      end

      def to_attribute( key, v, ref )
        case v
        when Hash
          ref[ key ].replace( v )
        else
          v
        end
      end

      def do_filter( data, ref )
        data.reject do |k,v|
          case v
          when Hash
            if babel = ref[ k.to_sym ]
              v.replace babel.replace( v ).attributes
              false
            else
              true
            end
          when ::Array
            if babel = ref[ k.to_sym ]
              v.each do |vv|
                vv.replace babel.replace( vv ).attributes
              end
              false
            else
              true
            end        
          else
            not ref.member?( k.to_sym ) 
          end
        end
      end
      
      def initialize
        super()
        replace( {} )
      end

      def replace( data )
        data = deep_dup( data )
        filter( data )
        hidden( data )
        self
      end

      private

      def deep_dup( data )
        data = data.dup
        data.each do |k,v|
          if v.is_a? Hash
            data[ k ] = deep_dup( v )
          end
        end
      end

      module ClassMethods
       
        def attribute( name, type = nil )
          attributes[ name.to_sym ] = new_instance( type )
        end

        def hidden( name, type = nil )
          hiddens[ name.to_sym ] = new_instance( type )
        end

        def data( meth )
          (superclass.send( "#{meth}s" ).dup rescue nil) || {}
        end
        private :data

        def set( meth, *args )
          args.each { |a| send( meth, a ) }
        end
        private :set

        def attributes( *args )
          if args.size == 0
            @attributes ||= data( :attributes )
          end
          set( :attribute, *args )
        end

        def hiddens( *args )
          if args.size == 0
            @hiddens ||= data( :hiddens )
          end
          set( :hidden, *args )
        end
        
        def new_instance( type )
          case type
          when Array
            type[ 0 ].new
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
