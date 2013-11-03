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

  let( :serializer ) { factory.new_serializer( person ) }

  let( :factory ) { Ixtlan::Babel::Factory.new }

  it 'should serialize and deserialize with methods' do
    class Person2Serializer < Ixtlan::Babel::Serializer
      add_context( :nested ) do
        only :id, :name, :age, :children_names, :children_ages
      end
    end
    json = serializer.use( :nested ).to_json
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
    class Person2Serializer < Ixtlan::Babel::Serializer
      add_context( :plain ) do
        only :id, :name
      end
    end
    json = serializer.use( :plain ).to_json
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ]
  end

  it 'should serialize and deserialize with root' do
    class Person2Serializer < Ixtlan::Babel::Serializer
      add_context( :root ) do
        root 'my'
        only :id, :name
      end
    end
    json = serializer.use( :root ).to_json
    result = MultiJson.load(json)[ 'my' ]
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ]
  end

  it 'should serialize and deserialize a hash with include list' do
    class Person2Serializer < Ixtlan::Babel::Serializer
      add_context( :deep_nested) do
        only( :id, :name, 
              :address => only( :street, :zipcode ),
              :phone_numbers => only( :prefix, :number ) )
      end
    end
    json = serializer.use( :deep_nested ).to_json
    result = MultiJson.load(json)
    result.must_equal Hash[ "id"=>"987", "name"=>"me and the corner" ,
                            "address"=> {
                              "street"=>"Foo 12",
                              "zipcode"=>"12345"
                            },
                            "phone_numbers"=> [ { "prefix"=>12,
                                                  "number"=>"123" } ] ]
  end

  it 'should serialize and deserialize with only' do
    class Person2Serializer < Ixtlan::Babel::Serializer
      add_context( :only ) do
        only :name
      end
    end
    json = serializer.use( :only ).to_json
    result = MultiJson.load(json)
    result.must_equal Hash[ "name"=>"me and the corner" ]
  end

  it 'should serialize and deserialize with nested only' do
    class Person2Serializer < Ixtlan::Babel::Serializer
      add_context( :nested_only ) do
        only :address => only( :street )
      end
    end
    json = serializer.use( :nested_only ).to_json
    result = MultiJson.load(json)
    result.must_equal Hash[ "address"=> {
                              "street"=>"Foo 12"
                            } ]
  end

  it 'should serialize and deserialize with nested include' do
    class Person2Serializer < Ixtlan::Babel::Serializer
      add_context( :nested_deep ) do
        only( :id, :name,
              :address => only( :street, :zipcode ),
              :phone_numbers => only( :prefix, 
                                      :number, 
                                      :area => only( :code, :iso) ) )
      end
    end
    json = serializer.use( :nested_deep ).to_json
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
