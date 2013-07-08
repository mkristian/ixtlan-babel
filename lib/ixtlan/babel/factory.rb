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
require 'ixtlan/babel/dm_validation_errors_serializer' if defined? DataMapper
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

      def add( clazz, &block )
        @map[ clazz.to_s ] = block
      end

      def new_serializer( resource )
        if resource.respond_to?(:model)
          model = resource.model
        elsif resource.respond_to?( :collect) &&
            !resource.respond_to?( :to_hash)
          if resource.empty?
            return EmptyArraySerializer.new
          else
            r = resource.first
            model = r.respond_to?( :model ) ? r.model : r.class
          end
        else
          model = resource.class
        end
        ser = const_retrieve( "#{model}Serializer" ).new( resource )
        ser.add_custom_serializers( @map )
        ser
      end

      def new( resource )
        warn 'DEPRECATED use new_serializer instead'
        new_serializer( resource )
      end

      def new_filter( clazz )
        const_retrieve( "#{clazz}Filter" ).new( clazz )
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
