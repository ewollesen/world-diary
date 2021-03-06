# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])


# Use a default port other than 3000
require "rails/commands/server"

module Rails
  class Server
    alias :default_options_alias :default_options
    def default_options
      default_options_alias.merge!(:Port => 16000)
    end
  end
end
