require 'spec_helper'

RSpec.describe Imperium::APIObject do
  let(:klass) { Class.new(Imperium::APIObject) { self.attribute_map = {'Foo' => :foo, 'Bar' => :bar} } }

  let(:attributes) { {'Foo' => 32, 'Bar' => 'baz'} }
  let(:obj) { klass.new(attributes) }

  describe '#initialize(attributes = {})' do
    it 'must be able to initialize an empty object' do
      klass.new
    end

    it 'must extract values from the hash using the incoming attribute names' do
      expect(obj.foo).to eq 32
      expect(obj.bar).to eq 'baz'
    end

    it 'must extract values from the hash using the ruby attribute names' do
      new_obj = klass.new(foo: 'baz', bar: 'qux')
      expect(new_obj.foo).to eq 'baz'
      expect(new_obj.bar).to eq 'qux'
    end
  end

  describe '#==(other)' do
    it 'must return false when another type of object is passed' do
      expect(obj).to_not eq 'wrong-type'
    end

    it 'must return false one or more of the attributes have changed' do
      other_obj = klass.new(foo: 'other/thing', bar: 'baz')
      expect(obj).to_not eq other_obj
    end

    it 'must return true when all the attributes are the same' do
      other_obj = klass.new(attributes)
      expect(obj).to eq other_obj
    end
  end

  describe '#to_h(consul_names_as_keys = true)' do
    context 'using consul names as keys' do
      it 'must use the consul names as keys' do
        expect(obj.to_h).to eq attributes
      end

      it 'must convert attributes that respond to to_h to hashes' do
        obj.foo = klass.new(foo: 42)
        expect(obj.to_h).to eq attributes.merge({'Foo' => {'Foo' => 42}})
      end

      it 'must convert array attributes to arrays of hashes' do
        obj.foo = [klass.new(foo: 42)]
        expect(obj.to_h).to eq attributes.merge('Foo' => [{'Foo' => 42}])
      end
    end

    it 'must use the ruby attribute names as keys when passed false' do
      expect(obj.to_h(consul_names_as_keys: false)).to eq(foo: 32, bar: 'baz')
    end
  end
end
