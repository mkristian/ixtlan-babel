require 'spec_helper'
require 'virtus'

class Address2
  include Virtus

  attribute :street, String
  attribute :zipcode, String
end
class Area2
  include Virtus

  attribute :code, String
  attribute :iso, String  
end
class PhoneNumber2
  include Virtus

  attribute :prefix, Integer
  attribute :number, String
  attribute :area, Area2
end
class Person2
  include Virtus

  attribute :id, String
  attribute :name, String
  attribute :address, Address2

  attr_accessor :phone_numbers, :age, :children_names

  def phone_numbers
    @phone_numbers ||= [PhoneNumber2.new( 
        :prefix => 12, 
        :number => '123',
        :area => Area2.new( :code => '001', :iso => 'us' ) )]
  end
  
  def age
    @age ||= 123
  end

  def children_names
    @children_names ||= ['anna', 'jack', 'rama', 'mia']
  end

  def children_ages
    @children_ages ||= [12, 3, 6, 9]
  end
end

describe Ixtlan::Babel::ModelFilter.to_s + ':with_methods' do
  let( :person ) do
   Person2.new( :id => 987,
                         :name => 'me and the corner',
                         :address => Address2.new( :street => 'Foo 12', :zipcode => '12345' ) )
  end

  let(:serializer) { Ixtlan::Babel::Serializer.new( person ) }
  let(:deserializer) { Ixtlan::Babel::Deserializer.new( Person2 ) }

  it 'should serialize and deserialize with methods' do
    json = serializer.to_json(:include => [:age, :children_names, :children_ages])
    data = MultiJson.load(json)
    data['age'].must_equal 123
    data['children_names'].must_equal ['anna', 'jack', 'rama', 'mia']
    data['children_ages'].must_equal [12, 3, 6, 9]
    result = deserializer.from_json(json)
    attributes = result.attributes.delete_if { |k,v| v.nil? }
    attributes.must_equal Hash[:id => person['id'], :name => person['name']]
  end

  it 'should serialize and deserialize without root' do
    json = serializer.to_json
    result = deserializer.from_json(json)
    attributes = result.attributes.delete_if { |k,v| v.nil? }
    attributes.must_equal Hash[:id => person['id'], :name => person['name']]
  end

  it 'should serialize and deserialize with root' do
    json = serializer.to_json :root => 'my'
    result = deserializer.from_json(json, :root => 'my')
    attributes = result.attributes.delete_if { |k,v| v.nil? }
    attributes.must_equal Hash[:id => person['id'], :name => person['name']]
  end  

  it 'should serialize and deserialize a hash with include list' do
    json = serializer.to_json(:include => ['address', 'phone_numbers'])   
    data = MultiJson.load(json)
    data['phone_numbers'][0]['prefix'].must_equal 12
    data['phone_numbers'][0]['number'].must_equal '123'
    result = deserializer.from_json(json, :include => ['address', 'phone_numbers'])
    result.object_id.wont_equal person.object_id
    result.address.attributes.must_equal person.address.attributes
    result.phone_numbers[0].area.must_be_nil
    person.phone_numbers[0].area = nil
    result.phone_numbers[0].prefix.must_equal person.phone_numbers[0].prefix
    result.phone_numbers[0].number.must_equal person.phone_numbers[0].number
    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'shouldserialize and deserialize with except' do
    json = serializer.to_json(:except => ['id'])  
    result = deserializer.from_json(json, :except => ['id'])  
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :id => nil]
    result = deserializer.from_json(json)  
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :id => nil]
  end

  it 'should serialize and deserialize with only' do
    json = serializer.to_json(:only => ['name']) 
    result = deserializer.from_json(json, :only => ['name'])
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :id => nil]
    result = deserializer.from_json(json)
    result.attributes.must_equal Hash[:name => person['name'], :address=>nil, :id => nil]
  end

  it 'should serialize and deserialize with nested only' do
    json = serializer.to_json(:include => { 'address' => {:only => ['street']}})
    result = deserializer.from_json(json, :include => { 'address' => {:only => ['street']}})

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested only (array includes)' do
    json = serializer.to_json(:include => { 'address' => {:only => ['street']}})
    result = deserializer.from_json(json, :include => ['address'])

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested except' do
    json = serializer.to_json(:include => { 'address' => {:except => ['zipcode']}})
    result = deserializer.from_json(json, :include => { 'address' => {:except => ['zipcode']}})

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested except (array includes)' do
    json = serializer.to_json(:include => { 'address' => {:except => ['zipcode']}})
    result = deserializer.from_json(json, :include => ['address'])

    json['phone_numbers'].must_be_nil
    json['address']['zipcode'].must_be_nil

    result.address.zipcode.must_be_nil

    result.name.must_equal person.name
    result.id.must_equal person.id
  end

  it 'should serialize and deserialize with nested include' do
    json = serializer.to_json(:include => { 'address' => {}, 'phone_numbers' => { :include => ['area']}}) 
    result = deserializer.from_json(json, :include => { 'address' => {}, 'phone_numbers' => { :include => ['area']}})

    result.object_id.wont_equal person.object_id
    result.address.attributes.must_equal person.address.attributes
    result.phone_numbers[0].area.code.must_equal person.phone_numbers[0].area.code
    result.phone_numbers[0].area.iso.must_equal person.phone_numbers[0].area.iso
    result.phone_numbers[0].prefix.must_equal person.phone_numbers[0].prefix
    result.phone_numbers[0].number.must_equal person.phone_numbers[0].number
    result.name.must_equal person.name
    result.id.must_equal person.id
  end
end
