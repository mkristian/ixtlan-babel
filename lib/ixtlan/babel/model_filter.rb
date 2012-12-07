module Ixtlan
  module Babel
    class ModelFilter < HashFilter

      def filter( model, &block )
        if model
          data = block.call( model )
          filter_data( model, data,
                       Config.new( options_for( data ) ),
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

      def filter_data(model, data, config, &block)
        config.methods.each do |m|
          unless data.include?(m)
            data[ m ] = model.send( m.to_sym )
          end
        end
        
        result = {}
        data.each do |k,v|
          k = k.to_s
          if v.respond_to? :attributes
            result[ k ] = filter_data( v, block.call(v), config[ k ], &block ) if config.include?( k )
          elsif v.is_a? Array
            result[ k ] = filter_array( v, config[ k ], &block ) if config.include?( k )
          else
            result[ k ] = serialize( v ) if config.allowed?( k ) && ! v.respond_to?( :attributes )
          end
        end
        result
      end
    end
  end
end
