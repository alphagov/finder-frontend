module ApiHelper
  def mock_api
    mock_api = double
    FinderFrontend.stub(:finder_api).and_return(mock_api)
    mock_api
  end
end
