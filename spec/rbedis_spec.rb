require "spec_helper"

describe Rbedis do
  it "has a VERSION" do
    Rbedis::VERSION.should =~ /^[\.\da-z]+$/
  end
end
