require_relative 'spec_helper'
require 'ixtlan/babel/model_serializer'
require 'virtus'
require 'multi_json'
require 'json'

Model = Virtus.model
class Address
  include Model

  attribute :street, String
  attribute :zipcode, String
end
class Area
  include Model

  attribute :code, String
  attribute :iso, String
end
class PhoneNumber
  include Model

  attribute :prefix, Integer
  attribute :number, String
  attribute :area, Area
end
class Person
  include Model

  attribute :id, String
  attribute :name, String
  attribute :address, Address

  attr_accessor :phone_numbers, :age, :children_names

  def phone_numbers
    @phone_numbers ||= [PhoneNumber.new(
        :prefix => 12,
        :number => '123',
        :area => Area.new( :code => '001', :iso => 'us' ) )]
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

class ASerializer
  include Ixtlan::Babel::ModelSerializer
  attributes :id, :name
end

class MethodsSerializer < ASerializer
  attributes :age, :children_names, :children_ages
end

class PhoneSerializer
  include Ixtlan::Babel::ModelSerializer
  attributes :prefix, :number
end

class AddressSerializer
  include Ixtlan::Babel::ModelSerializer
  attributes :street, :zipcode
end

class NestedListSerializer < ASerializer
  attribute :address, AddressSerializer
  attribute :phone_numbers, Array[PhoneSerializer]
end
class AreaSerializer
  include Ixtlan::Babel::ModelSerializer
  attributes :code, :iso
end

class Phone2Serializer < PhoneSerializer
  attribute :area, AreaSerializer
end
class DeepNestedSerializer < NestedListSerializer
  attribute :phone_numbers, Array[Phone2Serializer]
end

describe Ixtlan::Babel::ModelSerializer do
  let( :person ) do
    Person.new( :id => 987,
                :name => 'me and the corner',
                :address => Address.new( :street => 'Foo 12',
                                          :zipcode => '12345' ) )
  end

  it 'should serialize with methods' do
    data = MethodsSerializer.new( person )
    result = MultiJson.load(data.to_json)
    result.must_equal Hash[ "id"=>"987",
                            "name"=>"me and the corner",
                            "age"=>123,
                            "children_names"=> [ "anna",
                                                 "jack",
                                                 "rama",
                                                 "mia" ],
                            "children_ages"=>[ 12, 3, 6, 9 ] ]
    data.id.must_equal person.id
    data.name.must_equal person.name
    data.age.must_equal person.age
    data.children_ages.must_equal person.children_ages
  end

  it 'should serialize' do
    data = ASerializer.new( person )
    result = MultiJson.load(data.to_json)
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ]
    data.id.must_equal person.id
    data.name.must_equal person.name
    data.age.must_equal person.age
  end

  it 'should serialize with nested list' do
    data = NestedListSerializer.new( person )
    result = MultiJson.load( data.to_json )
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ,
                            "address"=> {
                              "street"=>"Foo 12",
                              "zipcode"=>"12345"
                            },
                            "phone_numbers"=> [ { "prefix"=>12,
                                                  "number"=>"123" } ] ]
    data.phone_numbers[0].prefix.must_equal result['phone_numbers'][0]['prefix']
    data.phone_numbers[0].number.must_equal result['phone_numbers'][0]['number']
  end

  it 'should serialize and deserialize with nested include' do
    data = DeepNestedSerializer.new( person )
    result = MultiJson.load( data.to_json )
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ,
                            "address"=> {
                              "street"=>"Foo 12",
                              "zipcode"=>"12345"
                            },
                            "phone_numbers"=> [ { "prefix"=>12,
                                                  "number"=>"123",
                                                  "area"=> {
                                                    "code"=>"001",
                                                    "iso"=>"us"
                                                  }
                                                } ] ]
    data.phone_numbers[0].prefix.must_equal result['phone_numbers'][0]['prefix']
    data.phone_numbers[0].number.must_equal result['phone_numbers'][0]['number']
    data.phone_numbers[0].area.code.must_equal result['phone_numbers'][0]['area']['code']
    data.phone_numbers[0].area.iso.must_equal result['phone_numbers'][0]['area']['iso']
  end
end
