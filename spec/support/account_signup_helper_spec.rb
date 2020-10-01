module AccountSignupHelper
  def self.test_ec_key_fixture
    OpenSSL::PKey::EC.new("prime256v1").generate_key.export
  end
end
