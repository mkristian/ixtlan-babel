require 'spec_helper'

class Hash
  def attributes
    self
  end
  def method_missing(method, *args)
    self[method.to_s]
  end
end

describe Ixtlan::Babel::HashFilter do
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

  let(:serializer) { Ixtlan::Babel::Serializer.new(data) }
  let(:deserializer) do
    f = Ixtlan::Babel::HashFilter.new
    def f.from_json( json, options = nil )
      data = MultiJson.load(json)
      self.options = options || {}
      if data.is_a? Array
        if filter.options[:root]
          data.collect do |d|
            Hash.new( self.filter( d[ self.options[:root] ] ) )
          end
        else
          data.collect{ |d| Hash.new( self.filter( d ) ) }
        end
      else
        data = data[ self.options[:root] ] if self.options[:root]
        Hash.new( self.filter( data ) )
      end
    end
    f
  end

  it 'should serialize and deserialize a hash' do
    json = serializer.to_json
    result = deserializer.from_json(json)
    result.must_equal Hash['id' => data['id'], 'name' => data['name']]
  end

  it 'should serialize and deserialize a hash with root' do
    json = serializer.to_json :root => 'my'
    result = deserializer.from_json(json, :root => 'my')
    result.must_equal Hash['id' => data['id'], 'name' => data['name']]
  end

  it 'should serialize and deserialize a hash with include list' do
    json = serializer.to_json(:include => ['address', 'phone_numbers'])
    result = deserializer.from_json(json, :include =>
                                    ['address', 'phone_numbers'])
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
    result = deserializer.from_json(json, :include =>
                                    { 'address' => {:only => ['street']}})
    result.must_equal data
    result = deserializer.from_json(json, :include => ['address'])
    result.must_equal data
  end

  it 'should serialize and deserialize a hash with nested except' do
    json = serializer.to_json(:include => { 'address' =>
                                {:except => ['zipcode']}})
    data.delete('phone_numbers')
    data['address'].delete('zipcode')
    result = deserializer.from_json(json, :include => { 'address' =>
                                      {:except => ['zipcode']}})
    result.must_equal data
    result = deserializer.from_json(json, :include => ['address'])
    result.must_equal data
  end

  it 'should serialize and deserialize a hash with nested include' do
    json = serializer.to_json(:include => { 'address' => {},
                                'phone_numbers' => { :include => ['area']}})
    result = deserializer.from_json(json, :include => { 'address' => {},
                                      'phone_numbers' => {
                                        :include => ['area']}})
    result.must_equal data
  end

  it 'should convert elements from arrays wth custom serializer' do
    serializer.add_custom_serializers( "Symbol" =>
                                       Proc.new {|v| v.to_s.capitalize } )
    data['children_names'] = [:adi, :aromal, :shreedev]
    d = serializer.to_hash(:include => [ :children_names ])
    d[ "children_names"].must_equal( ["Adi", "Aromal", "Shreedev"] )
  end
end
