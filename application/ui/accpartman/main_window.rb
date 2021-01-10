module Accpartman
  class MainWindow < Gtk::ApplicationWindow
    # Register the class in the GLib world
    type_register

    @account

    attr_reader :account

    class << self
      def init
        # Set the template from the resources binary
        set_template resource: '/com/munhozthemage/accpartman/ui/main_window.ui'
      
        # Create access to window components:

        # Value labels
        bind_template_child 'savings_value_label'
        bind_template_child 'planned_value_label'
        bind_template_child 'free_value_label'
        bind_template_child 'in_use_value_label'
        bind_template_child 'total_value_label'

        # Buttons
        bind_template_child 'add_button' # Bad name for: register_earning_button
        bind_template_child 'remove_button' # Bad name for: register_spending_button
        bind_template_child 'reallocate_button'
      end
    end

    def initialize(application, account)
      super application: application
    
      set_title 'Accpartman - Account Partitioning Manager'
      @account = account

      savings_value_label.text = @account.format_to_currency :savings
      planned_value_label.text = @account.format_to_currency :planned
      free_value_label.text = @account.format_to_currency :free
      in_use_value_label.text = @account.format_to_currency :in_use
      total_value_label.text = @account.format_to_currency :total
    
      add_button.signal_connect('clicked') { |button| add_button_action }
      remove_button.signal_connect('clicked') { |button| remove_button_action }
      reallocate_button.signal_connect('clicked') { |button| reallocate_button_action }
    end

    private
    def add_button_action
      open_money_operation_window("earning")
    end

    def remove_button_action
      open_money_operation_window("spending")
    end

    def reallocate_button_action
      # Open money reallocation window
      new_item_window = Accpartman::MoneyReallocationWindow.new(application, self)
      new_item_window.present
    end
    
    def open_money_operation_window(mode)
      new_item_window = Accpartman::MoneyOperationWindow.new(application, self, mode)
      new_item_window.present
    end
  end
end