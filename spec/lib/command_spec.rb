require 'spec_helper'

describe SimpleService::Command do

  class ValidCommand < SimpleService::Command
    expects :foo, :bar
    optional :stuff
    returns :bar, :baz
    def call
      context.merge!(
        bar: ['modified', self.stuff].compact.join(' '),
        baz: 'blah'
      )
    end
  end

  class InvalidReturnCommand < SimpleService::Command
    expects :foo
    returns :foo, :baz
    def call; true; end
  end


  class CallNotDefinedCommand < SimpleService::Command
  end

  describe '.call' do

    it 'returns the correct keys when using class method' do
      expect(
        ValidCommand.call(foo: 'blah', bar: 'meh')
      ).to eql(bar: 'modified', baz: 'blah')
    end

    it 'provides optional arguments as getters' do
      expect(
        ValidCommand.call(foo: 'blah', bar: 'meh', stuff: 'something')
      ).to eql(bar: 'modified something', baz: 'blah')
    end

  end

  describe '#call' do

    context 'when #returns is not empty' do
      it 'returns the correct keys from the context' do
        expect(
          ValidCommand.new(foo: 'blah', bar: 'meh').call
        ).to eql(bar: 'modified', baz: 'blah')
      end
    end

    context 'raises error' do

      it 'when command does not define an call method' do
        expect {
          CallNotDefinedCommand.new.call
        }.to raise_error(SimpleService::CallNotDefinedError)
      end

      it 'when command attempts to return a key that doesnt exist' do
        expect {
          InvalidReturnCommand.new.call
        }.to raise_error(SimpleService::ReturnKeyError)
      end

    end

  end

  describe 'context' do

    it 'defines getters for each expected key' do
      expect(
        ValidCommand.new(foo: 'blah', bar: 'meh')
      ).to respond_to :foo
    end

    it 'defines setters for each expected key' do
      command = ValidCommand.new(foo: 'blah', bar: 'meh')
      command.foo = 'changed'
      command.bar = 'changed'

      expect(command.context).to eql({ foo: 'changed', bar: 'changed' })
    end

    it 'getter updates @context' do
      command = ValidCommand.new(foo: 'blah', bar: 'meh')
      command.foo = 'changed'
      expect(command.context).to eql({ foo: 'changed', bar: 'meh'})
    end

  end

  describe '.get_expects' do

    it 'returns an array of expected keys' do
      expect(ValidCommand.get_expects.sort).to eql([:foo, :bar].sort)
    end

  end

  describe '.get_returns' do

    it 'returns an array of keys to return' do
      expect(ValidCommand.get_returns.sort).to eql([:baz, :bar].sort)
    end

  end

end
