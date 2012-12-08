require 'ixtlan/babel/abstract_filter'
module Ixtlan
  module Babel
    class ModelFilter < AbstractFilter

      def filter( model, &block )
        if model
          data = block.call( model )
          filter_data( model, data,
                       Context.new( options ),
                       &block ) 
        end
      end

      private

      def filter_array( models, options, &block )
        models.collect do |i|
          if i.respond_to? :attributes
            filter_data(i, block.call(i), options, &block)
          else
            i
          end
        end
      end

      def filter_data(model, data, context, &block)
        context.methods.each do |m|
          unless data.include?(m)
            data[ m ] = model.send( m.to_sym )
          end
        end
        
        result = {}
        data.each do |k,v|
          k = k.to_s
          if v.respond_to? :attributes
            result[ k ] = filter_data( v, block.call(v), context[ k ], &block ) if context.include?( k )
          elsif v.is_a? Array
            result[ k ] = filter_array( v, context[ k ], &block ) if context.include?( k )
          else
            result[ k ] = serialize( v ) if context.allowed?( k ) && ! v.respond_to?( :attributes )
          end
        end
        result
      end
    end
  end
end
