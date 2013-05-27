require "spec_helper"

describe Rbedis do
  it "has a VERSION" do
    Rbedis::VERSION.should =~ /^[a-z]+$/
  end
end
