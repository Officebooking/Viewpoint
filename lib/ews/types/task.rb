module Viewpoint::EWS::Types
  class Task
    include Viewpoint::EWS
    include Viewpoint::EWS::Types
    include Viewpoint::EWS::Types::Item
    
    TASK_KEY_PATHS = {
      complete?:         [:is_complete, :text],
      recurring?:        [:is_recurring, :text],
      start_date:        [:start_date, :text],
      due_date:          [:due_date, :text],
      reminder_due_by:   [:reminder_due_by, :text],
      reminder?:         [:reminder_is_set, :text],
      percent_complete:  [:percent_complete, :text],
      status:            [:status, :text],
      owner:             [:owner, :text],
   }

    TASK_KEY_TYPES = {
      recurring?:       ->(str){str.downcase == 'true'},
      complete?:        ->(str){str.downcase == 'true'},
      reminder?:        ->(str){str.downcase == 'true'},
      percent_complete: ->(str){str.to_i},
    }
    TASK_KEY_ALIAS = {}

    # Updates the specified attributes
    #
    # @param updates [Hash] with (:attribute => value)
    # @param options [Hash]
    # @option options :conflict_resolution [String] one of 'NeverOverwrite', 'AutoResolve' (default) or 'AlwaysOverwrite'
    # @return [Task, false]
    # @example Update Subject and Body
    #   item = #...
    #   item.update_item!(subject: 'New subject', due_date: Time.parse('25.03.2013 12:00'))

    def update_task!(updates, options = {})
      item_updates = []
      updates.each do |attribute, value|
        item_field = FIELD_URIS[attribute][:text] if FIELD_URIS.include? attribute
        field = {field_uRI: {field_uRI: item_field}}

        if value.nil? && item_field
          # Build DeleteItemField Change
          item_updates << {delete_item_field: field}
        elsif item_field
          # Build SetItemField Change
          item = Viewpoint::EWS::Template::Task.new(attribute => value)

          # Remap attributes because ews_builder #dispatch_field_item! uses #build_xml!
          item_attributes = item.to_ews_item.map do |name, value|
            if value.is_a? String
              {name => {text: value}}
            elsif value.is_a? Hash
              node = {name => {}}
              value.each do |attrib_key, attrib_value|
                attrib_key = camel_case(attrib_key) unless attrib_key == :text
                node[name][attrib_key] = attrib_value
              end
              node
            else
              {name => value}
            end
          end

          item_updates << {set_item_field: field.merge(task: {sub_elements: item_attributes})}
        else
          # Ignore unknown attribute
        end
      end

      if item_updates.any?
        data = {}
        data[:conflict_resolution] = options[:conflict_resolution] || 'AlwaysOverwrite'
        data[:item_changes] = [{item_id: self.item_id, updates: item_updates}]
        response_message = ews.update_item(data).response_messages.first
        if response_message && response_message.success?
          self.get_all_properties!
          self
        elsif response_message
          raise EwsCreateItemError, "Could not update task. #{response_message.code}: #{response_message.message_text}"
        else
          raise StandardError("No response message received.")
        end
      end

    end

    private

    def key_paths
      super.merge(TASK_KEY_PATHS)
    end

    def key_types
      super.merge(TASK_KEY_TYPES)
    end

    def key_alias
      super.merge(TASK_KEY_ALIAS)
    end

  end
end
