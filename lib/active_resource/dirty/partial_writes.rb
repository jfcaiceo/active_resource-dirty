module ActiveResource
  module Dirty
    module PartialWrites
      def self.included(base)
        base.class_attribute :partial_writes
      end
    end
  end
end
