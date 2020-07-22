module Fastlane
  module Actions
    class GooglePlayTrackVersionNameAction < Action
      # Supply::Options.available_options keys that apply to this action.
      OPTIONS = [
        :package_name,
        :track,
        :json_key,
        :json_key_data,
        :root_url,
        :timeout
      ]

      def self.run(params)
        require 'supply'
        require 'supply/options'

        Supply.config = params
        track = params[:track]

        client = Supply::Client.make_from_config

        client.begin_edit(package_name: Supply.config[:package_name])
        version_names = client.latest_version(track)
        client.abort_current_edit

        if version_names.nil?
          UI.important("No version name found in track '#{track}'")
          nil
        else
          UI.success("Found '#{version_names.name}' version name in track '#{track}'")
          version_names.name
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Retrieves version name for a Google Play track"
      end

      def self.available_options
        require 'supply'
        require 'supply/options'

        Supply::Options.available_options.select do |option|
          OPTIONS.include?(option.key)
        end
      end

      def self.output
      end

      def self.return_value
        "String or nil representing the last version name for the given Google Play track"
      end

      def self.authors
        ["PhilippeAuriach"]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.example_code
        [
          'version_name = google_play_track_version_name("production")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
