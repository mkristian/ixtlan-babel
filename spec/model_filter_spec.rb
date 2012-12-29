require 'spec_helper'
require 'virtus'

class Address
  include Virtus

  attribute :street, String
  attribute :zipcode, String
end
class Area
  include Virtus

  attribute :code, String
  attribute :iso, String  
end
class PhoneNumber
  include Virtus

  attribute :prefix, Integer
  attribute :number, String
  attribute :area, Area
end
class Person
  include Virtus

  attribute :id, String
  attribute :name, String
  attribute :address, Address
  attribute :phone_numbers, Array[PhoneNumber]
end

describe Ixtlan::Babel::ModelFilter do
  let( :person ) do
    Person.new(
      :id => 987,
      :name => 'me and the corner',
      :address => Address.new( :street => 'Foo 12', :zipcode => '12345' ),
      :phone_numbers => [PhoneNumber.new( 
        :prefix => 12, 
        :number => '123',
        :area => Area.new( :code => '001', :iso => 'us' )
      )]
    )
  end

  let(:serializer) { Ixtlan::Babel::Serializer.new( person ) }
  let(:deserializer) { Ixtlan::Babel::Deserializer.new( Person ) }

  it 'should serialize and deserialize without root' do
    json = serializer.to_json
    result = deserializer.from_json(json)

    # travis produces [] and locally there is a nil - filter empty as well :(
    attributes = result.attributes.delete_if { |k,v| v.nil? || v.empty? }

    attributes.must_equal Hash[:id => person['id'], :name => person['name']]
  end

  it 'should serialize and deserialize with root' do
    json = serializer.to_json :root => 'my'
    result = deserializer.from_json(json, :root => 'my')

    # travis produces [] and locally there is a nil - filter empty as well :(
    attributes = result.attributes.delete_if { |k,v| v.nil? || v.empty? }

    attributes.must_equal Hash[:id => person['id'], :name => person['name']]
  end  

  it 'should serialize and deserialize a hash with include list' do
    json = serializer.to_json(:include => ['address', 'phone_numbers']) 
    result = deserializer.from_json(json, :include => ['address', 'phone_numbers'])
    result.object_id.wont_equal person.object_id
    result.address.attributes.must_equal person.address.attributes
    result.phone_numbers[0].area.must_be_nil
    person.phone_numbers[0].area = nil
    result.phone_numbers[0].attributes.must_equal person.phone_numbers[0].attributes
    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with except' do
    json = serializer.to_json(:except => ['id'])  
    result = deserializer.from_json(json, :except => ['id'])  
    
    # travis sees empty array and locally it is nil :(
    result.attributes[ :phone_numbers ] ||= []
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :phone_numbers=>[], :id => nil]

    result = deserializer.from_json(json)

    # travis sees empty array and locally it is nil :(
    result.attributes[ :phone_numbers ] ||= []
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :phone_numbers=>[], :id => nil]
  end

  it 'should serialize and deserialize with only' do
    json = serializer.to_json(:only => ['name']) 
    result = deserializer.from_json(json, :only => ['name'])

    # travis sees empty array and locally it is nil :(
    result.attributes[ :phone_numbers ] ||= []
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :phone_numbers=>[], :id => nil]

    result = deserializer.from_json(json)

    # travis sees empty array and locally it is nil :(
    result.attributes[ :phone_numbers ] ||= []
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :phone_numbers=>[], :id => nil]
  end

  it 'should serialize and deserialize with nested only' do
    json = serializer.to_json(:include => { 'address' => {:only => ['street']}})
    result = deserializer.from_json(json, :include => { 'address' => {:only => ['street']}})

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    # travis produces [] and locally there is a nil :(
    (result.phone_numbers || []).must_equal []

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested only (array includes)' do
    json = serializer.to_json(:include => { 'address' => {:only => ['street']}})
    result = deserializer.from_json(json, :include => ['address'])

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    # travis produces [] and locally there is a nil :(
    (result.phone_numbers || []).must_equal []

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested except' do
    json = serializer.to_json(:include => { 'address' => {:except => ['zipcode']}})
    result = deserializer.from_json(json, :include => { 'address' => {:except => ['zipcode']}})

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    # travis produces [] and locally there is a nil :(
    (result.phone_numbers || []).must_equal []

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested except (array includes)' do
    json = serializer.to_json(:include => { 'address' => {:except => ['zipcode']}})
    result = deserializer.from_json(json, :include => ['address'])

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    # travis produces [] and locally there is a nil :(
    (result.phone_numbers || []).must_equal []

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested include' do
    json = serializer.to_json(:include => { 'address' => {}, 'phone_numbers' => { :include => ['area']}}) 
    result = deserializer.from_json(json, :include => { 'address' => {}, 'phone_numbers' => { :include => ['area']}})

    result.object_id.wont_equal person.object_id
    result.address.attributes.must_equal person.address.attributes
    result.phone_numbers[0].area.attributes.must_equal person.phone_numbers[0].area.attributes
    result.phone_numbers[0].prefix.must_equal person.phone_numbers[0].prefix
    result.phone_numbers[0].number.must_equal person.phone_numbers[0].number
    result.name.must_equal person.name
    result.id.must_equal person.id
  end
end
