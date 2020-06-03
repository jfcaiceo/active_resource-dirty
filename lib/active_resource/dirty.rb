require 'active_resource/dirty/patch_updates'

module ActiveResource
  module Dirty
    # Save the record and clears changed attributes if successful.
    def save_without_validation(*)
      run_callbacks :save do
        saved = new? ? create : update
        changes_applied if saved
        saved
      end
    end

    # <tt>reload</tt> the record and clears changed attributes.
    def reload(*)
      super.tap do
        clear_changes_information
      end
    end

    def update_attributes(attributes)
      unless attributes.respond_to?(:to_hash)
        raise ArgumentError, 'expected attributes to be able to convert'\
          " to Hash, got #{attributes.inspect}"
      end

      attributes = attributes.to_hash
      attributes.each do |key, value|
        send("#{key}=".to_sym, value)
      end

      save
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.end_with?('=') || super
    end

    # Monkey patch
    def changes_applied
      if new_active_model_version?
        super
      else
        @previously_changed = changes
        @attributes_changed_by_setter = ActiveSupport::HashWithIndifferentAccess.new
      end
    end

    private

    def new_active_model_version?
      ActiveModel::VERSION::MAJOR == 6
    end

    def method_missing(method_symbol, *arguments) #:nodoc:
      method_name = method_symbol.to_s
      attribute_name = method_name.match(/^(.+)=$/)&.captures&.first
      if attribute_name && known_attributes.include?(attribute_name)
        new_value = arguments.first

        if attribute_changed?(attribute_name) && changed_attributes[attribute_name] == new_value
          # Reset status if already changed and we are returning to the original value
          clear_attribute_changes([attribute_name])
        elsif attributes[attribute_name] != new_value
          # yield change if value changed otherwise
          attribute_will_change!(attribute_name)
        end
      end
      super
    end

    # Monkey patch
    def mutations_from_database
      @mutations_from_database ||= if new_active_model_version?
                                     ActiveModel::ForcedMutationTracker.new(self)
                                   else
                                     ActiveModel::NullMutationTracker.instance
                                   end
    end

    # Monkey patch
    def forget_attribute_assignments; end

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
                         encode(only: keys_for_partial_write),
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
