require 'test_helper'

describe Person do

  let(:person) { Person.new(name: 'name', email: 'email') }

  it 'can be constructed by a hash' do
    e = Person.new(name:'name', email: 'email', type: 't')
    e.name.must_equal 'name'
    e.email.must_equal 'email'
  end

  it 'can be constructed from a string' do
    e = Person.new('email (name)')
    e.name.must_equal 'name'
    e.email.must_equal 'email'

    e = Person.new('name')
    e.name.must_equal 'name'
    e.email.must_be_nil
  end

  it 'can turn into a hash' do
    e = person.as_json
    e[:name].must_equal 'name'
    e[:email].must_equal 'email'
  end
end
