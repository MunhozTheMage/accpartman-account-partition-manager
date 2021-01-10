module Accpartman
  class MoneyReallocationWindow < Gtk::Window
    # Register the class in the GLib world
    type_register

    @main_window

    class << self
      def init
        # Set the template from the resources binary
        set_template resource: '/com/munhozthemage/accpartman/ui/money_reallocation_window.ui'
      
        # Create access to window components:
        bind_template_child 'from_category_combo_box'
        bind_template_child 'to_category_combo_box'
        bind_template_child 'value_input'
        bind_template_child 'confirm_reallocation_button'
      end
    end

    def initialize(application, main_window)
      super application: application
      set_title "Accpartman - Reallocation"
      
      @main_window = main_window

      # Show combo box options
      start_partitions_combo_box from_category_combo_box
      start_partitions_combo_box to_category_combo_box

      # Set actions
      confirm_reallocation_button.signal_connect('clicked') { |button| confirm_action }
    end

    private

    def account
      @main_window.account
    end

    def confirm_action
      input_float_value = value_input.text.to_valid_float

      confirmation_is_valid = 
      from_category_combo_box.active >= 0 && 
      to_category_combo_box.active >= 0 &&
      input_float_value != 0.0

      if confirmation_is_valid
        origin_partition = Accpartman::Account::PARTITION_NAMES[from_category_combo_box.active]
        destination_partition = Accpartman::Account::PARTITION_NAMES[to_category_combo_box.active]

        origin_modified_value = account.partition_spend origin_partition, input_float_value
        destination_modified_value = account.partition_earn destination_partition, input_float_value

        origin_partition_label = @main_window.send "#{origin_partition}_value_label"
        origin_partition_label.text = origin_modified_value

        destination_partition_label = @main_window.send "#{destination_partition}_value_label"
        destination_partition_label.text = destination_modified_value

        @main_window.total_value_label.text = account.format_to_currency :total

        close
      end
    end

    def start_partitions_combo_box(combo_box)
      model = Gtk::ListStore.new(String)
      Accpartman::Account::PARTITION_NAMES.each do |partition_name|
        iterator = model.append
        iterator[0] = partition_name.to_s.gsub('_', ' ').capitalize
      end
    
      combo_box.model = model
      renderer = Gtk::CellRendererText.new
      combo_box.pack_start(renderer, true)
      combo_box.set_attributes(renderer, "text" => 0)
    end
  end
end