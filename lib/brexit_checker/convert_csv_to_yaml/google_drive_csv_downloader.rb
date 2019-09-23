require "google/apis/drive_v3"
require "googleauth/stores/file_token_store"

module BrexitChecker
  module ConvertCsvToYaml
    class GoogleDriveCsvDownloader
      attr_reader :sheet_id, :download_destination

      CREDENTIALS_PATH = "credentials.json".freeze
      # The file token.yaml stores the user's access and refresh tokens, and is
      # created automatically when the authorization flow completes for the first
      # time.
      TOKEN_PATH = "token.yaml".freeze
      AUTH_SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_READONLY
      OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze

      def initialize(sheet_id, download_destination)
        @sheet_id = sheet_id
        @download_destination = download_destination
      end

      def download
        drive_service = Google::Apis::DriveV3::DriveService.new
        drive_service.authorization = authorize
        drive_service.export_file(sheet_id,
                                  "text/csv",
                                  download_dest: download_destination)
        puts "> CSV downloaded to #{download_destination}"
      end

    private

      def authorize
        client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
        authorizer = Google::Auth::UserAuthorizer.new(client_id, AUTH_SCOPE, token_store)
        user_id = "default"
        credentials = authorizer.get_credentials(user_id)

        unless credentials
          url = authorizer.get_authorization_url(base_url: OOB_URI)
          puts "Open the following URL in the browser and enter the " \
               "resulting code after authorization:\n" + url
          code = gets
          credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI,
          )
        end
        credentials
      end
    end
  end
end
