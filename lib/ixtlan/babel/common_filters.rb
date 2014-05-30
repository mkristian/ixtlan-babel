require 'ixtlan/babel/hash_filter'
require 'ixtlan/babel/model_serializer'

class Ixtlan::Babel::IdFilter
  include Ixtlan::Babel::HashFilter

  attributes :id
end

class Ixtlan::Babel::UpdatedAtFilter
  include Ixtlan::Babel::HashFilter

  hidden :updated_at
end

class Ixtlan::Babel::CollectionSerializer
  include Ixtlan::Babel::ModelSerializer

  attributes :offset, :total_count
end

