require 'spec_helper'

describe Sycamore do
  it 'has a version number' do
    expect(Sycamore::VERSION).not_to be_nil
    expect(Sycamore::VERSION).to match /\d\.\d.\d/
  end

end
