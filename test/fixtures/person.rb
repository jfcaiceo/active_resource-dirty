class Person < ActiveResource::Base
  self.site = 'http://someapi.com'
  self.patch_updates = true

  schema do
    attribute :write_only, :string
  end

  def self.with_custom_patch_flag(flag)
    original_value = patch_updates
    self.patch_updates = flag
    yield
  ensure
    self.patch_updates = original_value
  end
end
