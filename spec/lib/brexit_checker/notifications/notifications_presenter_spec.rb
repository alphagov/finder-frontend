require "spec_helper"

RSpec.describe BrexitChecker::Notifications::NotificationsPresenter do
  it "generates valid configuration" do
    presenter = described_class.new(%w[Z001 Z002], %w[C001])

    presenter.notifications["notifications"].each do |notification_hash|
      notification = BrexitChecker::Notification.load(notification_hash)
      expect(notification).to be_valid
    end
  end
end
