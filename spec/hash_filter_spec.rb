require_relative 'spec_helper'
require 'ixtlan/babel/hash_filter'
require 'yaml'
class A; end
class AFilter 
  include Ixtlan::Babel::HashFilter

  attributes :id, :name
end
class HiddenFilter < AFilter
  attributes.delete( :id )
  hidden :id
end
class AddressFilter
  include Ixtlan::Babel::HashFilter
  attributes :street
end
class PhoneFilter
  include Ixtlan::Babel::HashFilter
  attributes :prefix, :number
end
class AreaFilter
  include Ixtlan::Babel::HashFilter
  attributes :code, :iso
end
class Phone2Filter < PhoneFilter
  attribute :area, AreaFilter
end
class NestedFilter < AFilter
  attribute :address, AddressFilter
end
class NestedArrayFilter < AFilter
  attribute :phone_numbers, Array[PhoneFilter]
end
class DeepNestedFilter < NestedArrayFilter
  attribute :phone_numbers, Array[Phone2Filter]
end

class Hash
  def attributes
    self
  end
  def method_missing(method)
    self[method.to_s]
  end
end

describe Ixtlan::Babel::HashFilter do
  let(:data) do
    {
      'id' => 987,
      'name' => 'me and the corner',
      'address' => { 'street' => 'Foo 12', 'zipcode' => '12345' },
      'phone_numbers' => [ {
        'prefix' => 12,
        'number' => '123',
        'area' => { 'code' => '001', 'iso' => 'us'}
      } ]
    }
  end

  it 'should filter a hash' do
    result = AFilter.new.replace( data )
    result.params.must_equal Hash[ 'id' => data['id'], 'name' => data['name'] ]
    result.id.must_equal data['id']
    result.name.must_equal data['name']
  end

  it 'should filter a hash with hidden' do
    result = HiddenFilter.new.replace( data )
    result.params.must_equal Hash[ 'name' => data['name'] ]
    result.id.must_equal data['id']
    result.name.must_equal data['name']
  end

  it 'should filter a hash with nested' do
    result = NestedFilter.new.replace( data )
    data.delete( 'phone_numbers' )
    data['address'].delete('zipcode')
    result.params.to_yaml.must_equal data.to_yaml
    result.address.street.must_equal data['address']['street']
  end

  it 'should filter a hash with nested array' do
    result = NestedArrayFilter.new.replace( data )
    data.delete( 'address' )
    data['phone_numbers'].delete('area')
    result.params.to_yaml.must_equal data.to_yaml
    result.phone_numbers[0].prefix.must_equal data['phone_numbers'][0]['prefix']
    result.phone_numbers[0].number.must_equal data['phone_numbers'][0]['number']
  end

  it 'should filter a hash with deep nested' do
    result = DeepNestedFilter.new.replace( data )
    data.delete( 'address' )
    result.params.to_yaml.must_equal data.to_yaml
    result.phone_numbers[0].prefix.must_equal data['phone_numbers'][0]['prefix']
    result.phone_numbers[0].number.must_equal data['phone_numbers'][0]['number']
    result.phone_numbers[0].area.code.must_equal data['phone_numbers'][0]['area']['code']
    result.phone_numbers[0].area.iso.must_equal  data['phone_numbers'][0]['area']['iso']
  end
end
