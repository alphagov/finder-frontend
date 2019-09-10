require "spec_helper"

describe BrexitChecker::ConvertCsvToYaml::GoogleDriveCsvDownloader do
  include FixturesHelper

  let(:csv_to_download) { actions_csv_to_convert_to_yaml }
  let(:downloaded_csv_destination) { Tempfile.new("downloaded.csv").path }
  let(:sheet_id) { "a-sheet-id" }
  let(:client_id) { double("Google::Auth::ClientId", id: "some-id") }
  let(:user_refresh_credentials) do
    double("Google::Auth::UserRefreshCredentials", client_id: "some-id")
  end

  describe "#download" do
    before do
      allow($stdout).to receive(:puts)
      api_url = "https://www.googleapis.com/drive/v3/files/#{sheet_id}/export?alt=media&mimeType=text/csv"
      stub_request(:get, api_url).to_return(body: File.open(csv_to_download))
    end

    it "downloads a CSV from Google Drive to a given location" do
      allow(Google::Auth::ClientId).to receive(:from_file).and_return(client_id)
      allow_any_instance_of(Google::Auth::UserAuthorizer).to receive(:get_credentials)
                                                         .and_return(user_refresh_credentials)

      downloader = described_class.new(sheet_id, downloaded_csv_destination)
      downloader.download

      parsed_csv_to_download = CSV.read(csv_to_download)
      parsed_downloaded_csv = CSV.read(downloaded_csv_destination)

      expect(parsed_downloaded_csv).to eq(parsed_csv_to_download)
    end
  end
end
