module AccountPartitioningManager
  class Application < Gtk::Application
    attr_reader :user_data_path

    def initialize
      super 'com.munhozthemage.accpartman', Gio::ApplicationFlags::FLAGS_NONE

      # Creates directory if not exists.
      @user_data_path = File.expand_path('~/.accpartman')
      unless File.directory?(@user_data_path)
        puts "First run. Creating user's application path: #{@user_data_path}"
        FileUtils.mkdir_p(@user_data_path)
      end

      # Dropbox compatibility
      # Will ONLY use dropbox if there is a accpartman folder inside
      @dropbox_path = File.expand_path('~/Dropbox/accpartman')
      unless File.directory?(@dropbox_path)
        @dropbox_path = nil
      end

      # Show window
      signal_connect :activate do |application|
        window = Accpartman::MainWindow.new(
          application,
          Accpartman::Account.new(user_data_path: @user_data_path, dropbox_path: @dropbox_path)
        )
        window.present
      end
    end
  end
end