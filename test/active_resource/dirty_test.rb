require 'test_helper'

class ActiveResource::Dirty::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ActiveResource::Dirty
  end
end
