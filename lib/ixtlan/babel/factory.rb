module Ixtlan
  module Babel
    class Factory

      NANOSECONDS_IN_DAY = Rational(1, 86400*10**9)

      TIME_TO_S = Proc.new do |t|
        t.strftime('%Y-%m-%dT%H:%M:%S.') + ("%06d" % t.usec) + t.strftime('%z')
      end

      DATE_TIME_TO_S = Proc.new do |dt|
        dt.strftime('%Y-%m-%dT%H:%M:%S.') + ("%06d" % (dt.sec_fraction / NANOSECONDS_IN_DAY / 1000)) + dt.strftime('%z')
      end
      
      DEFAULT_MAP = {
        'DateTime' => DATE_TIME_TO_S,
        'ActiveSupport::TimeWithZone' => TIME_TO_S,
        'Time' => TIME_TO_S
      }

      class EmptyArraySerializer < Array
        def use(arg)
          self
        end
      end

      def initialize(custom_serializers = {})
        @map = DEFAULT_MAP.dup
        @map.merge!(custom_serializers)
      end

      def add(clazz, &block)
        @map[clazz.to_s] = block
      end

      def new(resource)
        if resource.respond_to?(:model)
          model = resource.model
        elsif resource.respond_to? :collect
          if resource.empty?
            return EmptyArraySerializer.new
          else
            r = resource.first
            model = r.respond_to?(:model) ? r.model : r.class
          end
        else
          model = resource.class
        end
        ser = const_retrieve("#{model}Serializer").new(resource)
        ser.add_custom_serializers(@map)
        ser
      end

      def const_retrieve( const )
        obj = Object
        const.split(/::/).each do |part|
          obj = obj.const_get( part )
        end
        obj
      end
    end
  end
end
