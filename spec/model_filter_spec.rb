require 'spec_helper'
require 'virtus'
require 'ixtlan/babel/serializer'

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
  attribute :children_names, Array[Symbol]
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
      )],
      :children_names => [:adi, :aromal, :shreedev]
    )
  end

  let(:serializer) { Ixtlan::Babel::Serializer.new( person ) }

  it 'should serialize and deserialize without root' do
    json = serializer.to_json
    result = MultiJson.load(json)
    result.must_equal Hash['id' => person['id'], 'name' => person['name']]
  end

  it 'should serialize and deserialize with root' do
    json = serializer.to_json :root => 'my'
    result = MultiJson.load(json)[ 'my' ]
    result.must_equal Hash['id' => person['id'], 'name' => person['name']]
  end

  it 'should serialize and deserialize a hash with include list' do
    json = serializer.to_json(:include => ['address', 'phone_numbers'])
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987",
                            "name"=>"me and the corner",
                            "address"=>{
                              "street"=>"Foo 12",
                              "zipcode"=>"12345"
                            },
                            "phone_numbers"=> [ {"prefix"=>12,
                                                  "number"=>"123" } ] ]
  end

  it 'should serialize and deserialize with except' do
    json = serializer.to_json(:except => ['id'])
    result = MultiJson.load(json)
    result.must_equal Hash['name' => person['name']]
  end

  it 'should serialize and deserialize with only' do
    json = serializer.to_json(:only => ['name'])
    result = MultiJson.load(json)

    result.must_equal Hash['name' => person['name']]
  end

  it 'should serialize and deserialize with nested only' do
    json = serializer.to_json(:include => { 'address' => {:only => ['street']}})
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987",
                             "name"=>"me and the corner",
                             "address"=>{ "street"=>"Foo 12" } ]
  end

  it 'should serialize and deserialize with nested except' do
    json = serializer.to_json(:include =>
                              { 'address' => {:except => ['zipcode']}})
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987",
                            "name"=>"me and the corner",
                            "address"=>{ "street"=>"Foo 12" } ]
  end

  it 'should serialize and deserialize with nested include' do
    json = serializer.to_json( :include => {
                                 'address' => {},
                                 'phone_numbers' => { :include => ['area'] }
                               } )
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987",
                            "name"=>"me and the corner",
                            "address"=>{ "street"=>"Foo 12",
                              "zipcode"=>"12345" },
                            "phone_numbers"=>[ { "prefix"=>12,
                                                 "number"=>"123",
                                                 "area"=>{
                                                   "code"=>"001",
                                                   "iso"=>"us"
                                                 }
                                               } ] ]
  end

  it 'should convert elements from arrays wth custom serializer' do
    serializer.add_custom_serializers( "Symbol" =>
                                       Proc.new {|v| v.to_s.capitalize } )
    data = serializer.to_hash(:include => [ :children_names ])
    data[ "children_names"].must_equal( ["Adi", "Aromal", "Shreedev"] )
  end
end
