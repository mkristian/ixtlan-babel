require 'spec_helper'

class Hash
  def attributes
    self
  end
  def method_missing(method)
    self[method.to_s]
  end
end

describe Babel do
  let(:data) do
    data = {
      'id' => 987,
      'name' => 'me and the corner',
      'address' => { 'street' => 'Foo 12', 'zipcode' => '12345' },
      'phone_numbers' => { 
        'prefix' => 12, 
        'number' => '123',
        'area' => { 'code' => '001', 'iso' => 'us'}
      }
    }
    class Hash
      def self.new(hash = nil, &block) 
        if hash
          self[hash]
        else 
          super &block
        end
      end
    end
    data
  end

  let(:serializer) { Babel::Serializer.new(data) }
  let(:deserializer) { Babel::Deserializer.new(Hash) }

  it 'should serialize and deserialize a hash' do
    json = serializer.to_json
    result = deserializer.from_json(json)
    result.must_equal Hash['id' => data['id'], 'name' => data['name']]
  end

  it 'should serialize and deserialize a hash with root' do
    json = serializer.to_json :root => :my
    result = deserializer.from_json(json, :root => :my)
    result.must_equal Hash['id' => data['id'], 'name' => data['name']]
  end  

  it 'should serialize and deserialize a hash with include list' do
    json = serializer.to_json(:include => ['address', 'phone_numbers']) 
    result = deserializer.from_json(json, :include => ['address', 'phone_numbers'])
    data['phone_numbers'].delete('area')
    result.must_equal Hash[data]
  end

  it 'should serialize and deserialize a hash with except' do
    json = serializer.to_json(:except => ['id'])  
    result = deserializer.from_json(json, :except => ['id'])  
    result.must_equal Hash['name' => data['name']]
    result = deserializer.from_json(json)  
    result.must_equal Hash['name' => data['name']]
  end

  it 'should serialize and deserialize a hash with only' do
    json = serializer.to_json(:only => ['name']) 
    result = deserializer.from_json(json, :only => ['name'])
    result.must_equal Hash['name' => data['name']]
    result = deserializer.from_json(json)
    result.must_equal Hash['name' => data['name']]
  end

  it 'should serialize and deserialize a hash with nested only' do
    json = serializer.to_json(:include => { 'address' => {:only => ['street']}})
    data.delete('phone_numbers')
    data['address'].delete('zipcode')
    result = deserializer.from_json(json, :include => { 'address' => {:only => ['street']}})
    result.must_equal data
    result = deserializer.from_json(json, :include => ['address'])
    result.must_equal data
  end

  it 'should serialize and deserialize a hash with nested except' do
    json = serializer.to_json(:include => { 'address' => {:except => ['zipcode']}}) 
    data.delete('phone_numbers')
    data['address'].delete('zipcode')
    result = deserializer.from_json(json, :include => { 'address' => {:except => ['zipcode']}})
    result.must_equal data
    result = deserializer.from_json(json, :include => ['address'])
    result.must_equal data
  end

  it 'should serialize and deserialize a hash with nested include' do
    json = serializer.to_json(:include => { 'address' => {}, 'phone_numbers' => { :include => ['area']}}) 
    result = deserializer.from_json(json, :include => { 'address' => {}, 'phone_numbers' => { :include => ['area']}})
    result.must_equal data
  end
end
