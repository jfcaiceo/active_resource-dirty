module ActiveResource
  module Dirty
    module PatchUpdates
      def self.included(base)
        base.class_attribute :patch_updates
      end
    end
  end
end
