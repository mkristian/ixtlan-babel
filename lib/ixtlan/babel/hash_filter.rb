module Ixtlan
  module Babel
    class HashFilter

      def initialize(context_or_options = nil)
        use(context_or_options)
      end
      
      private

      def context
        @context ||= {}
      end

      public

      def add_custom_serializers(map)
        @map = map
      end

      def default_context_key(single = :single, collection = :collection)
        @single, @collection = single, collection
      end

      def []=(key, options)
        context[key.to_sym] = options if key
      end

      def [](key)
        context[key.to_sym] if key
      end

      def use(context_or_options)
        if context_or_options
          case context_or_options
          when Symbol  
            if opts = context[context_or_options]
              @options = opts.dup
            end
          when Hash
            @options = context_or_options
          end
        else
          @options = nil
        end
        self
      end

      NO_MODEL = Object.new
      def NO_MODEL.send(*args)
        self
      end
      def NO_MODEL.[](*args)
        self
      end

      def filter(hash = {}, model = NO_MODEL, &block)
        filter_data(model, hash, hash.is_a?(Array) ? collection_options : single_options, &block) if hash
      end

      def single_options
        @options || context[default_context_key[0]] || {}
      end

      def collection_options
        @options || context[default_context_key[1]] || {}
      end

      def root
        @root ||= single_options[:root]
      end

      private

      def filter_data(model, data, options = {}, &block)
        model = NO_MODEL if model == data
        only = options[:only].collect { |o| o.to_s } if options[:only]
        except = (options[:except] || []).collect { |e| e.to_s }

        include =
          case options[:include]
          when Array
            options[:include].collect { |i| i.to_s }
          when Hash
            Hash[options[:include].collect {|k,v| [k.to_s, v]}]
          else
            []
          end
        if model != NO_MODEL
          methods = (options[:methods] || []).collect { |e| e.to_s }
          methods.each do |m|
            data[m] = model.send(m.to_sym)
          end

          include_methods = include.is_a?(Array) ? include : include.keys 
          include_methods.each do |m|
            unless data.include?(m)
              raise "no block given to calculate the attributes from model" unless block
              models_or_model = model.send(m)
              if models_or_model.is_a?(Array) && models_or_model.first.is_a?(String)
                data[m] = models_or_model
              elsif models_or_model.respond_to?(:collect)
                data[m] = models_or_model.collect { |i| block.call(i) }
              else
                val = model.send(m)
                case val
                when Fixnum
                  data[m] = val
                when String
                  data[m] = val
                when TrueClass
                  data[m] = val
                else
                  data[m]= block.call(val)
                end
              end
            end
          end
        end
        methods ||= []
        result = {}
        data.each do |k,v|
          case v
          when Hash
            if include.include?(k.to_s)
              case include
              when Array
                result[k.to_s] = filter_data(model.send(k), v, &block)
              when Hash
                result[k.to_s] = filter_data(model.send(k), v, include[k.to_s], &block)
              end
            end
          when Array
            if include.include?(k.to_s)
              models = model.send(k)
              j = -1
              case include
              when Array
                result[k.to_s] = v.collect do |i| 
                  j += 1
                  if i.is_a?(Array) || i.is_a?(Hash)
                    filter_data(models[j], i, &block)
                  else
                    i
                  end
                end
              when Hash
                opts = include[k.to_s]
                result[k.to_s] = v.collect do |i| 
                  j += 1
                  ndata = i.is_a?(Hash)? i : block.call(i)
                  filter_data(models[j], ndata, opts, &block)
                end
              end
            end
          else
            if methods.include?(k.to_s) || (only && only.include?(k.to_s)) || (only.nil? && !except.include?(k.to_s))
              if @map && ser = @map[v.class.to_s]
                result[k.to_s] = ser.call(v)
              else
                result[k.to_s] = v
              end
            end
          end
        end
        result
      end
    end
  end
end
