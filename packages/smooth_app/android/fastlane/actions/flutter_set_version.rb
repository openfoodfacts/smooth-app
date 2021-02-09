module Fastlane
  module Actions
    module SharedValues
      FLUTTER_SET_VERSION_CUSTOM_VALUE = :FLUTTER_SET_VERSION_CUSTOM_VALUE
    end

    class FlutterSetVersionAction < Action
      def self.run(params)


        versionName = params[:version_name]
        versionCode = params[:version_code]
        path = params[:path_to_yaml]

        # Checking values
        if !File.exists?(path)
            raise 'File not found at path: "' + path + '" example: ../myFolder/pubspec.yaml'
        end
        unless !versionName.to_s.strip.empty?
            raise "newVersion must not be null"
        end


        #Processing string
        versionToSet = "version: "
        unless versionCode.to_s.strip.empty?
            versionToSet.concat(versionName)
            versionToSet.concat('+')
            versionToSet.concat(versionCode)
        else
            versionToSet.concat(versionName)
        end


        #Read data
        lines = IO.readlines(path).map do |line|
        if (line.include? "version:")
            versionToSet
        else
            line
        end
        end

        # Write changes
        File.open(path, 'w') do |file|
          file.puts lines
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This sets the version number in the pubspey.yaml"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..., I am not able to add to this, its just right."
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :version_name,
                                       description: "The new version to be set {major}.{minor}.{patch}", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No version given, pass using `newVersion: 'the version'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_code,
                                      description: "The new build version", # a short description of this parameter
                                      verify_block: proc do |value|
                                          UI.user_error!("No version code given, pass using `version_code: 'your version_code'`") unless (value and not value.empty?)
                                      end),
          FastlaneCore::ConfigItem.new(key: :path_to_yaml,
                                       description: "Create a development certificate instead of a distribution one",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['FLUTTER_SET_VERSION_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
