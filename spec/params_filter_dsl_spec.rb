require 'spec_helper'
require 'ixtlan/babel/params_filter'

class A; end
class AFilter < Ixtlan::Babel::ParamsFilter

end

class Hash
  def attributes
    self
  end
  def method_missing(method)
    self[method.to_s]
  end
end

describe Ixtlan::Babel::ParamsFilter do
  let(:data) do
    {
      'id' => 987,
      'name' => 'me and the corner',
      'address' => { 'street' => 'Foo 12', 'zipcode' => '12345' },
      'list' => [1,2,3,4],
      'phone_numbers' => {
        'prefix' => 12,
        'number' => '123',
        'area' => { 'code' => '001', 'iso' => 'us'}
      }
    }
  end

  let(:factory) { Ixtlan::Babel::Factory.new }
  let(:filter) { factory.new_filter( A ) }
  let(:deserializer) { Ixtlan::Babel::Deserializer.new(Hash) }

  it 'should filter a hash' do
    AFilter.add_context( :plain )
    result = filter.use( :plain ).filter_it( data )
    result.params.must_equal Hash[]
    result.size.must_equal 1
  end

  it 'should filter a hash with keep' do
    class AFilter
      add_context( :keep ) do
        keep :id
      end
    end
    result = filter.use( :keep ).filter_it( data )
    result.params.must_equal Hash[]
    result.id.must_equal data['id']
    result.size.must_equal 2
  end

  it 'should filter a hash with root' do
    class AFilter
      add_context( :root ) do
        root 'my'
        only :id, :name
      end
    end
    result = filter.use( :root ).filter_it( 'my' => data )
    result.params.must_equal Hash[ 'id' => data['id'], 'name' => data['name'] ]
    result.size.must_equal 1
  end

  it 'should filter a nested object' do
    class AFilter
      add_context( :nested ) do
        only( :id, :name,
              :address => only( :street, :zipcode),
              :phone_numbers => only( :prefix, :number ) )
      end
    end
    result = filter.use( :nested ).filter_it( data )

    data['phone_numbers'].delete('area')
    data.delete('list')
    result.params.must_equal Hash[data]
    result.size.must_equal 1
  end

  it 'should filter a hash with only' do
    class AFilter
      add_context( :only ) do
        only :name
      end
    end
    result = filter.use( :only ).filter_it( data )
    result.params.must_equal Hash['name' => data['name']]
    result.size.must_equal 1
  end

  it 'should filter a hash with only and keep' do
    class AFilter
      add_context( :only_and_keep ) do
        keep :id
        only :name
      end
    end
    result = filter.use( :only_and_keep ).filter_it( data )
    result.params.must_equal Hash['name' => data['name']]
    result.id.must_equal data['id']
    result.size.must_equal 2
  end

  it 'should filter a hash with nested only' do
    class AFilter
      add_context( :filtered_nested ) do
        only :id, :name, :list, :address => only( :street )
      end
    end
    result = filter.use( :filtered_nested ).filter_it( data )
    data.delete('phone_numbers')
    data['address'].delete('zipcode')
    result.params.must_equal Hash[data]
    result.size.must_equal 1
  end

  it 'should filter a hash with deep nested include' do
    class AFilter
      add_context( :deep_nested ) do
        only( :id, :name, :list,
              :address => only( :street, :zipcode), 
              :phone_numbers => only( :prefix, :number,
                                      :area => only( :code, :iso ) ) )
      end
    end
    result = filter.use( :deep_nested ).filter_it( data )
    result.params.must_equal Hash[data]
    result.size.must_equal 1
  end
end
