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
                         :address => Address2.new( :street => 'Foo 12',
                                                   :zipcode => '12345' ) )
  end

  let(:serializer) { Ixtlan::Babel::Serializer.new( person ) }

  it 'should serialize and deserialize with methods' do
    json = serializer.to_json( :include =>
                               [:age, :children_names, :children_ages])
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987",
                            "name"=>"me and the corner",
                            "age"=>123,
                            "children_names"=> [ "anna",
                                                 "jack",
                                                 "rama",
                                                 "mia" ],
                            "children_ages"=>[ 12, 3, 6, 9 ] ]
  end

  it 'should serialize and deserialize without root' do
    json = serializer.to_json
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ]
  end

  it 'should serialize and deserialize with root' do
    json = serializer.to_json :root => 'my'
    result = MultiJson.load(json)[ 'my' ]
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ]
  end

  it 'should serialize and deserialize a hash with include list' do
    json = serializer.to_json(:include => ['address', 'phone_numbers'])
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ,
                            "address"=> {
                              "street"=>"Foo 12",
                              "zipcode"=>"12345"
                            },
                            "phone_numbers"=> [ { "prefix"=>12,
                                                  "number"=>"123" } ] ]
  end

  it 'shouldserialize and deserialize with except' do
    json = serializer.to_json(:except => ['id'])
    result = MultiJson.load(json)
    result.must_equal Hash[ "name"=>"me and the corner" ]
  end

  it 'should serialize and deserialize with only' do
    json = serializer.to_json(:only => ['name'])
    result = MultiJson.load(json)
    result.must_equal Hash[ "name"=>"me and the corner" ]
  end

  it 'should serialize and deserialize with nested only' do
    json = serializer.to_json(:include => { 'address' => {
                                  :only => ['street'] } } )
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ,
                            "address"=> {
                              "street"=>"Foo 12"
                            } ]
  end

  it 'should serialize and deserialize with nested except' do
    json = serializer.to_json(:include => {
                                'address' => {:except => ['zipcode'] } } )
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ,
                            "address"=> {
                              "street"=>"Foo 12"
                            } ]
  end

  it 'should serialize and deserialize with nested include' do
    json = serializer.to_json(:include => {
                                'address' => {},
                                'phone_numbers' => { :include => ['area'] }
                              } )
    result = MultiJson.load(json)
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
  end
end
