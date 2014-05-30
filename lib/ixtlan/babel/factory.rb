require 'ixtlan/babel/hash_filter'
require 'ixtlan/babel/model_serializer'
module Ixtlan
  module Babel
    
    class Factory

      NANOSECONDS_IN_DAY = 86400*10**6

      TIME_TO_S = Proc.new do |t|
        t.strftime('%Y-%m-%dT%H:%M:%S.') + ("%06d" % t.usec) + t.strftime('%z')
      end

      DATE_TIME_TO_S = Proc.new do |dt|
        dt.strftime('%Y-%m-%dT%H:%M:%S.') + ("%06d" % (dt.sec_fraction * NANOSECONDS_IN_DAY ) )[0..6] + dt.strftime('%z')
      end

      DATE_TO_S = Proc.new do |d|
        d.strftime('%Y-%m-%d' )
      end

      DEFAULT_MAP = {
        'DateTime' => DATE_TIME_TO_S,
        'Date' => DATE_TO_S,
        'ActiveSupport::TimeWithZone' => TIME_TO_S,
        'Time' => TIME_TO_S
      }

      def initialize( custom_serializers = {} )
        @map = DEFAULT_MAP.dup
        @map.merge!( custom_serializers )
      end

      def serializer( resource, context = nil )
        if model = to_model( resource )
          clazz = '::' + model.to_s
          to_class( clazz, 'Serializer', context ).new( resource, @map )
        else
          []
        end
      end

      private
      def to_model( resource )
        if resource.respond_to?(:model)
          resource.model
        elsif( resource.respond_to?( :collect ) &&
               !resource.respond_to?( :to_hash ) )
          if resource.empty?
            nil
          else
            to_model( resource.first )
          end
        else
          resource.class
        end
      end

      def to_class( clazz, postfix, context )
        if context.is_a? Class
          context
        else
          context = context.to_s.split( /_/ ).collect { |s| s.capitalize }.join
          c = clazz.to_s.sub( /^::/, '' ).sub( /(::)?([a-zA-Z0-9]+)$/, "\\1#{context}\\2#{postfix}" )
          obj = Object
          c.split( /::/ ).each do |part|
            obj = obj.const_get( part )
          end
          obj
        end
      end
    end
  end
end
