require 'spec_helper'

describe Cts::Mpx do
  it "is expected to have loaded the service references" do
    expect(Cts::Mpx::Services['Media Data Service']).not_to be nil
  end
  it "is expected to have loaded the root registry" do
    expect(Cts::Mpx::Registry.domains).not_to be({})
  end

  it 'has a version number' do
    expect(Cts::Mpx::VERSION).not_to be nil
  end
end
