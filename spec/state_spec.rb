require 'spec_helper'

module Ovto
  describe State do
    describe '.item' do
      it 'with default value' do
        class WithDefaultValue < State
          item :foo, default: 1
        end
        state = WithDefaultValue.new
        expect(state.foo).to eq(1)
      end

      context 'no default value' do
        before :all do
          class NoDefaultValue < State
            item :foo
          end
        end

        it 'should raise error if no value given' do
          expect{ NoDefaultValue.new }.to raise_error(State::MissingValue)
        end

        it 'should be ok if a value is given' do
          state = NoDefaultValue.new(foo: 1)
          expect(state.foo).to eq(1)
        end
      end
    end

    describe '.new' do
      before :all do
        class NewTest < State
          item :foo
          item :bar
        end
      end

      it 'raises an error for unknown key' do
        expect {
          NewTest.new(foo: 1, bar: 2, baz: 3)
        }.to raise_error(State::UnknownStateKey)
      end
    end

    describe '#merge' do
      before :all do
        class MergeTest < State
          item :foo
          item :bar
        end
      end

      it 'creates new hash' do
        state = MergeTest.new(foo: 1, bar: 2)
        new_state = state.merge(bar: 3)

        expect(new_state.to_h).to eq({foo: 1, bar: 3})
      end

      it 'does not change the original' do
        state = MergeTest.new(foo: 1, bar: 2)
        state.merge(bar: 3)
        expect(state.to_h).to eq({foo: 1, bar: 2})
      end

      it 'raises an error for unknown key' do
        state = MergeTest.new(foo: 1, bar: 2)
        expect {
          state.merge(baz: 3)
        }.to raise_error(State::UnknownStateKey)
      end
    end

    describe '#==' do
      before :all do
        class EqTest < State
          item :foo
          item :bar
        end
      end

      it 'returns true if equal' do
        s1 = EqTest.new(foo: 1, bar: 2)
        s2 = EqTest.new(foo: 1, bar: 2)
        expect(s1 == s2).to be_truthy
      end

      it 'returns false if not equal' do
        s1 = EqTest.new(foo: 1, bar: 2)
        s2 = EqTest.new(foo: 1, bar: 3)
        expect(s1 == s2).to be_falsy
      end
    end
  end
end
