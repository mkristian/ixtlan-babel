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
    result = filter.filter_it( data )
    result.params.must_equal Hash[ 'id' => data['id'], 'name' => data['name'] ]
    result.size.must_equal 1
  end

  it 'should filter a hash with keep' do
    result = filter.use( :keep => ['id'] ).filter_it( data )
    result.params.must_equal Hash[ 'name' => data['name'] ]
    result[ 'id' ].must_equal data['id']
    result.size.must_equal 2
  end

  it 'should filter a hash with root' do
    result = filter.use( :root => 'my' ).filter_it( 'my' => data )
    result.params.must_equal Hash[ 'id' => data['id'], 'name' => data['name'] ]
    result.size.must_equal 1
  end

  it 'should filter a hash with include list' do
    result = filter.use( :include => ['address',
                                    'phone_numbers'] ).filter_it( data )

    data['phone_numbers'].delete('area')
    result.params.must_equal Hash[data]
    result.size.must_equal 1
  end

  it 'should filter a hash with except' do
    result = filter.use( :except => ['id'] ).filter_it( data )
    result.params.must_equal Hash['name' => data['name']]
    result.size.must_equal 1
  end

  it 'should filter a hash with except and keep' do
    result = filter.use( :except => ['id'], :keep => ['id'] ).filter_it( data )
    result.params.must_equal Hash['name' => data['name']]
    result['id'].must_equal data['id']
  end

  it 'should filter a hash with only' do
    result = filter.use( :only => ['name'] ).filter_it( data )
    result.params.must_equal Hash['name' => data['name']]
    result.size.must_equal 1
  end

  it 'should filter a hash with only and keep' do
    result = filter.use( :only => ['name'], :keep => ['id'] ).filter_it( data )
    result.params.must_equal Hash['name' => data['name']]
    result[ 'id' ].must_equal data['id']
    result.size.must_equal 2
  end

  it 'should filter a hash with nested only' do
    result = filter.use( :include => { 'address' =>
                         {:only => ['street']}} ).filter_it( data )
    data.delete('phone_numbers')
    data['address'].delete('zipcode')
    result.params.must_equal Hash[data]
    result.size.must_equal 1
  end

  it 'should filter a hash with nested except' do
    result = filter.use( :include => { 'address' =>
                         {:except => ['zipcode']}} ).filter_it( data )
    data.delete('phone_numbers')
    data['address'].delete('zipcode')
    result.params.must_equal Hash[data]
    result.size.must_equal 1
  end

  it 'should filter a hash with nested include' do
    result = filter.use( :include => { 'address' => {}, 'phone_numbers' =>
                         { :include => ['area']}} ).filter_it( data )
    result.params.must_equal Hash[data]
    result.size.must_equal 1
  end
end
