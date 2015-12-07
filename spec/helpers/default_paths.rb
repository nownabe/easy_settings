shared_context "default_paths" do
  let!(:gem_root) { File.expand_path("../../../", __FILE__) }
  let!(:config_path) { File.join(gem_root, "config") }
  let!(:spec_root) { File.join(gem_root, "spec") }
  let!(:spec_config_path) { File.join(spec_root, "config") }

  before do
    FileUtils.mkdir config_path
  end

  after do
    FileUtils.rm_rf config_path
  end

  let(:test_settings_file) do
    File.join(spec_config_path, "settings.yml")
  end

  let(:default_settings_path1) { File.join(gem_root, "settings.yml") }
  let(:default_settings_path2) { File.join(config_path, "settings.yml") }

  let(:settings) { Class.new(EasySettings) }
end
