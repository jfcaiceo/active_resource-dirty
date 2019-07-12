require 'active_resource/dirty/patch_updates'

module ActiveResource
  module Dirty
    # Save the record and clears changed attributes if successful.
    def save(*)
      if (status = super)
        changes_applied
      end
      status
    end

    # <tt>reload</tt> the record and clears changed attributes.
    def reload(*)
      super.tap do
        clear_changes_information
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.end_with?('=') || super
    end

    # Monkey patch
    def changes_applied
      @previously_changed = changes
      @attributes_changed_by_setter = ActiveSupport::HashWithIndifferentAccess.new
    end

    private

    def method_missing(method_symbol, *arguments) #:nodoc:
      method_name = method_symbol.to_s
      if method_name =~ /(=)$/ && attributes.key?($`)
        new_value = arguments.first

        if attribute_changed?($`) && changed_attributes[$`] == new_value
          # Reset status if already changed and we are returning to the original value
          clear_attribute_changes([$`])
        elsif attributes[$`] != new_value
          # yield change if value changed otherwise
          attribute_will_change!($`)
        end
      end
      super
    end

    # Monkey patch
    def mutations_from_database
      @mutations_from_database ||= ActiveModel::NullMutationTracker.instance
    end

    # Monkey patch
    def forget_attribute_assignments; end

    def encode_changed_attributes(options = {})
      format_options = options.merge(only: keys_for_partial_write)
      send("to_#{self.class.format.extension}", format_options)
    end

    def keys_for_partial_write
      changed_attributes.keys
    end

    protected

    # Update the resource on the remote service.
    def update
      return super unless patch_updates

      return if changed_attributes.blank?

      run_callbacks :update do
        connection.patch(element_path(prefix_options),
                         encode_changed_attributes,
                         self.class.headers).tap do |response|
          load_attributes_from_response(response)
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_resource) do
  prepend ActiveResource::Dirty
  include ActiveModel::Dirty
  include ActiveResource::Dirty::PatchUpdates
end
