require File.expand_path("../rails_helper", __FILE__)

describe EasySettings do
  subject { described_class }
  its(:namespace) { is_expected.to eq Rails.env }
  its(:app_name)  { is_expected.to eq "Test App for EasySettings" }
  its(:endpoint)  { is_expected.to eq "https://endpoint-for-test" }
  its(:apikey)    { is_expected.to eq "EASYSETTINGS" }
end
