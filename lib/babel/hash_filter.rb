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

    def default_context_key(default = nil)
      @default = default if default
      @default
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

    def filter(hash = {}, model = NO_MODEL, &block)
      filter_data(model, hash, options, &block) if hash
    end

    def options
      @options || context[default_context_key] || {}
    end

    private

    def filter_data(model, data, options = {}, &block)
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
            if models_or_model.respond_to?(:collect)
              data[m] = models_or_model.collect { |i| block.call(i) }
            else
              data[m]= block.call(model.send(m))
            end
          end
        end
      end
      methods ||= []

      result = {}
      data.each do |k,v|
        case v
        when Hash
          if include.include?(k)
            case include
            when Array
              result[k] = filter_data(model.send(k), v, &block)
            when Hash
              result[k] = filter_data(model.send(k), v, include[k], &block)
            end
          end
        when Array
          if include.include?(k)
            models = model.send(k)
            case include
            when Array
              result[k] = v.enum_with_index.collect { |i, j| filter_data(models[j], i, &block) }
            when Hash
              opts = include[k]
              result[k] = v.enum_with_index.collect { |i, j| filter_data(models[j], i, opts, &block) }
            end
          end
        else
          if methods.include?(k) || (only && only.include?(k)) || (only.nil? && !except.include?(k))
            result[k] = v
          end
        end
      end
      result
    end
  end
end
