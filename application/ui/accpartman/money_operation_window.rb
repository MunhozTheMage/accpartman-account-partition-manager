module Accpartman
  class MoneyOperationWindow < Gtk::Window
    # Register the class in the GLib world
    type_register

    @main_window
    @mode

    class << self
      def init
        # Set the template from the resources binary
        set_template resource: '/com/munhozthemage/accpartman/ui/money_operation_window.ui'
      
        # Create access to window components:
        bind_template_child 'value_input'
        bind_template_child 'category_combo_box'
        bind_template_child 'confirm_operation_button'
      end
    end

    def initialize(application, main_window, mode)
      super application: application
      set_title "Accpartman - Register #{mode.capitalize}"
      
      @main_window = main_window
      @mode = mode

      # Change button text
      confirm_operation_button.label = "Confirm " + mode.capitalize

      # Show combo box options
      model = Gtk::ListStore.new(String)
      Accpartman::Account::PARTITION_NAMES.each do |partition_name|
        iterator = model.append
        iterator[0] = partition_name.to_s.gsub('_', ' ').capitalize
      end
    
      category_combo_box.model = model
      renderer = Gtk::CellRendererText.new
      category_combo_box.pack_start(renderer, true)
      category_combo_box.set_attributes(renderer, "text" => 0)

      # Set actions
      confirm_operation_button.signal_connect('clicked') { |button| confirm_action }
    end

    private

    def account
      @main_window.account
    end

    def confirm_action
      input_float_value = value_input.text.to_valid_float

      if category_combo_box.active >= 0 && input_float_value != 0.0
        partition = Accpartman::Account::PARTITION_NAMES[category_combo_box.active]

        modified_value = @mode == 'earning' ? 
        account.partition_earn(partition, input_float_value) 
        : 
        account.partition_spend(partition, input_float_value)

        partition_label = @main_window.send "#{partition}_value_label"
        partition_label.text = modified_value
        @main_window.total_value_label.text = account.format_to_currency :total

        close
      end
    end
  end
end