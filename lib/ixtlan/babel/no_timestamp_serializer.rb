require 'ixtlan/babel/serializer'
module Ixtlan
  module Babel
    class NoTimestampSerializer < Serializer
      
      def self.add_defaults(root = nil)
        if root
          add_context(:default, :root => root)
          add_no_timestamp_context(:collection, :root => root)
        else
          add_context(:default)
          add_no_timestamp_context(:collection)
        end
      end

      def self.add_no_timestamp_context(key, options = {})
        except = (options[:except] || []).dup
        except << :updated_at
        except << :created_at
        add_context(key, options.merge({:except => except}))
      end
    end
  end
end
