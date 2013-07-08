require 'ixtlan/babel/serializer'
class DataMapper::Validations::ValidationErrorsSerializer < Ixtlan::Babel::Serializer

  def to_hash( o = nil)
    @model_or_models.to_hash
  end

end
