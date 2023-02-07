module ResearchBannerHelper
  UKMCAB_FINDER = "/uk-market-conformity-assessment-bodies".freeze

  def show_banner?(path)
    UKMCAB_FINDER == path
  end
end
