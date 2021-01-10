require 'json'

module Accpartman
  class Account
    # Constant
    PARTITION_NAMES = [:savings, :planned, :free, :in_use].freeze

    # Variables
    @filename

    attr_accessor *PARTITION_NAMES
    attr_accessor :filename

    def initialize(options = {})
      if user_data_path = options[:user_data_path]
        @filename = "#{user_data_path}/account.json"

        begin
          load_from_file @filename
        rescue
          @savings = 0.00.to_s
          @planned = 0.00.to_s
          @free = 0.00.to_s
          @in_use = 0.00.to_s
          save!
        end
      else
        raise ArgumentError, 'Please specify the :user_data_path'
      end
    end

    def load_from_file(filename)
      properties = JSON.parse(File.read(filename))
      PARTITION_NAMES.each do |partition_name|
        self.send "#{partition_name}=", properties[partition_name.to_s]
      end
    rescue => e
      raise ArgumentError, "Failed to load existing item: #{e.message}"
    end

    # Resolves if an item is new
    def is_new?
      !File.exists? @filename
    end

    def save!
      File.open(@filename, 'w') do |file|
        file.write self.to_json
      end
    end

    def to_json
      result = {}
      PARTITION_NAMES.each do |partition|
        result[partition] = self.send partition
      end

      result.to_json
    end

    def total
      total = PARTITION_NAMES.reduce(0.00) do |acc, partition|
        acc + send(partition).to_f
      end
  
      total.to_s
    end

    def change_attribute!(partition_symbol, new_value)
      send "#{partition_symbol}=", new_value
      save!
      format_to_currency partition_symbol
      # Returns formated string
    end

    def format_to_currency(partition_symbol)
      "R$ #{'%.2f' % send(partition_symbol)}"
    end

    def increment_account_attribute!(partition_symbol, ammount)
      raise "ammount must be a number." if ammount.class != Integer && ammount.class != Float

      new_value = (send(partition_symbol).to_f + ammount.to_f).to_s
      change_attribute! partition_symbol, new_value
      # Returns formated string
    end

    def partition_earn(partition_symbol, value)
      value *= -1 if value < 0
      increment_account_attribute! partition_symbol, value
    end

    def partition_spend(partition_symbol, value)
      value *= -1 if value > 0
      increment_account_attribute! partition_symbol, value
    end
  end
end