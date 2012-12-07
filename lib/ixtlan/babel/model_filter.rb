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
#puts "-" * 80
#p data
        #methods = (options[:methods] || []).collect { |e| e.to_s }
        #config.methods.each do |m|
        #  data[ m ] = model.send( m )
        #end

        #include_methods = include.is_a?(Array) ? include : include.keys 

        config.methods.each do |m|
          unless data.include?(m)
            data[ m ] = model.send( m.to_sym )
          end
        end
        # config.methods.each do |m|
        #   unless data.include?(m)
        #     val = model.send( m.to_sym )
        #     if val.is_a?(Array) && val.first.is_a?( String )
        #       data[ m ] = val
        #     elsif val.respond_to?( :collect )
        #       data[ m ] = val.collect { |i| block.call( i ) }
        #     else
        #       case val
        #       when Fixnum
        #         data[ m ] = val
        #       when String
        #         data[ m ] = val
        #       when TrueClass
        #         data[ m ] = val
        #       else
        #         data[ m ]= block.call( val )
        #       end
        #     end
        #   end
        # end
        
        result = {}
        data.each do |k,v|
          k = k.to_s
          if v.respond_to? :attributes
            result[ k ] = filter_data( v, block.call(v), config[ k ], &block ) if config.include?( k )

            # if include.include?(k.to_s)
            #   case include
            #   when Array
            #     result[k.to_s] = filter_data(model.send(k), v, &block)
            #   when Hash
            #     result[k.to_s] = filter_data(model.send(k), v, include[k.to_s], &block)
            #   end
            # end
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
