require 'ixtlan/babel/context'
module Ixtlan
  module Babel
    class AbstractFilter

      attr_accessor :options

      def options
        @options || {}
      end
        
      def add_custom_serializers( map )
        @map = map
      end

      def serialize( data )
        if @map && ser = @map[ data.class.to_s ]
          ser.call(data)
        else
          data
        end
      end
      
    end
  end
end
