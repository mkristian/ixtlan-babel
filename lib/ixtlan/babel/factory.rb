module Ixtlan
  module Babel
    class Factory

      NANOSECONDS_IN_DAY = Rational(1, 86400*10**9)

      class EmptyArraySerializer < Array
        def use(arg)
          self
        end
      end

      def initialize(custom_serializers = {})
        @map = {}
        add('DateTime') do |dt|
          dt.strftime('%Y-%m-%dT%H:%M:%S.') + ("%06d" % (dt.sec_fraction / NANOSECONDS_IN_DAY / 1000)) + dt.strftime('%z')
        end
        add('ActiveSupport::TimeWithZone') do |tz|
          tz.strftime('%Y-%m-%dT%H:%M:%S.') + ("%06d" % tz.usec) + tz.strftime('%z')
        end
        add('Time') do |t|
          t.strftime('%Y-%m-%dT%H:%M:%S.') + ("%06d" % t.usec) + t.strftime('%z')
        end
        @map.merge!(custom_serializers)
      end

      def add(clazz, &block)
        @map[clazz.to_s] = block
      end

      def new(resource)
        if resource.respond_to?(:model)
          model = resource.model
        elsif resource.is_a? Array
          if resource.empty?
            return EmptyArraySerializer.new
          else
            r = resource.first
            model = r.respond_to?(:model) ? r.model : r.class
          end
        else
          model = resource.class
        end
        ser = Object.const_get("#{model}Serializer").new(resource)
        ser.add_custom_serializers(@map)
        ser
      end
    end
  end
end
