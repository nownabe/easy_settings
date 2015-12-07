shared_examples_for "EasySettings" do |proc|
  let(:settings, &proc)

  it "can access by dot" do
    expect(settings.app_name).to eq app_name
  end

  it "can access by [Srting]" do
    expect(settings["app_name"]).to eq app_name
  end

  it "can access by [Symbol]" do
    expect(settings[:app_name]).to eq app_name
  end

  it "can access nested hash by dot" do
    expect(settings.admins.admin1.password).to eq "PassWord1"
  end

  it "can access nested hash by []" do
    expect(settings[:admins][:admin1][:password]).to eq "PassWord1"
  end

  it "return nil when access key that doesn't exist by dot" do
    expect(settings.admins.admin3).to be_nil
  end

  it "return nil when access key that doesn't exist by []" do
    expect(settings[:admins][:admin3]).to be_nil
  end

  it "can be set value by dot" do
    settings.foo = :bar
    expect(settings.foo).to eq :bar

    admin3 = { "password" => "PassWord3", "role" => "administrator" }
    settings.admins.admin3 = admin3
    expect(settings.admins.admin3.to_h).to eq admin3
  end

  it "can be set value by []" do
    settings[:foo] = :bar
    expect(settings.foo).to eq :bar

    admin3 = { "password" => "PassWord3", "role" => "administrator" }
    settings[:admins][:admin3] = admin3
    expect(settings.admins.admin3.to_h).to eq admin3
  end

  it "can be rewrited by dot" do
    settings.app_name = "hoge"
    expect(settings.app_name).to eq "hoge"

    password = "PASSWORD"
    settings.admins.admin1 = password
    expect(settings.admins.admin1).to eq password
  end

  it "can be rewrited by []" do
    settings[:app_name] = "hoge"
    expect(settings.app_name).to eq "hoge"

    password = "PASSWORD"
    settings[:admins][:admin1] = password
    expect(settings.admins.admin1).to eq password
  end

  it "can treat ERB format" do
    unless settings.source_hash
      expect(settings.erb).to eq "This was set by ERB"
    end
  end

  describe "method?" do
    it "return true when key exist" do
      expect(settings.app_name?).to be_truthy
    end

    it "return false when key doesn't exist" do
      expect(settings.not_exist?).to be_falsey
    end
  end

  describe "method!" do
    it "return new hash when key doesn't exist" do
      ret = settings.newkey!
      expect(ret).to be_an_instance_of settings
      expect(ret.to_h).to eq({})
    end

    it "return existing value when key exist" do
      expect(settings.app_name!).to eq app_name
    end
  end

  describe "method_" do
    it "return new hash but doesn't set when key doesn't exist" do
      ret = settings.newkey_
      expect(ret).to be_an_instance_of settings
      expect(ret.to_h).to eq({})
      expect(settings.newkey).to be_nil
    end

    it "return existing value when key exist" do
      expect(settings.app_name_).to eq app_name
    end
  end

  describe "method()" do
    it "can set new value when key doesn't exist" do
      new_value = "NEWVAL"
      expect(settings.newkey(new_value)).to eq new_value
      expect(settings.newkey).to eq new_value
    end

    it "doesn't set new value when key already exist" do
      expect(settings.app_name("NEWVAL")).to eq "EasySettingsTest"
      expect(settings.app_name).to eq "EasySettingsTest"
    end

    it "can set nil when using nil option" do
      expect(settings.newkey(nil, nil: true)).to be_nil
      expect(settings.key?(:newkey)).to be_truthy
      expect(settings.newkey).to be_nil
    end

    it "doesn't set nil when not using nil option" do
      expect(settings.newkey(nil)).to be_nil
      expect(settings.key?(:newkey)).to be_falsey
    end
  end
end

require "helpers/default_paths"

describe EasySettings do
  include_context "default_paths"

  let(:custom_settings_path) do
    File.expand_path("../../config/application.yml", __FILE__)
  end

  let(:app_name) do
    "EasySettingsTest"
  end

  context "from settings.yml" do
    before do
      FileUtils.cp test_settings_file, default_settings_path1
    end

    after do
      FileUtils.rm_f default_settings_path1
    end

    it_behaves_like("EasySettings", proc { Class.new(EasySettings) })

    describe ".reload!" do
      it "can reload source" do
        expect(settings.app_name).to eq app_name
        settings.source_hash = { app_name: "RELOAD" }
        expect(settings.reload!).to be_truthy
        expect(settings.app_name).to eq "RELOAD"
      end
    end
  end

  context "from config/settings.yml" do
    before do
      FileUtils.cp test_settings_file, default_settings_path2
    end

    after do
      FileUtils.rm_f default_settings_path2
    end

    it_behaves_like("EasySettings", proc { Class.new(EasySettings) })
  end

  context "from custom path" do
    before do
      FileUtils.cp test_settings_file, custom_settings_path
    end

    after do
      FileUtils.rm_f custom_settings_path
    end

    it_behaves_like(
      "EasySettings",
      proc do
        Class.new(EasySettings) do
          self.source_file = File.expand_path("../../config/application.yml", __FILE__)
        end
      end
    )
  end

  context "from source hash" do
    it_behaves_like(
      "EasySettings",
      proc do
        source_file = File.expand_path("../config/settings.yml", __FILE__)
        Class.new(EasySettings) do
          self.source_file = source_file
          self.source_hash = YAML.load_file(source_file)
        end
      end
    )
  end

  context "with namespace" do
    it_behaves_like(
      "EasySettings",
      proc do
        Class.new(EasySettings) do
          self.source_file = File.expand_path("../config/namespace.yml", __FILE__)
          self.namespace   = "test"
        end
      end
    )
  end

  context "source does not exist" do
    it "EasySettings is empty hash" do
      expect(settings.to_h).to eq({})
    end
  end

  context "with empty source" do
    it "EasySettings become empty hash" do
      settings.source_file = File.join(spec_config_path, "empty.yml")
      expect(settings.to_h).to eq({})
    end
  end

  context "specify wrong source path" do
    it "raise error" do
      settings.source_file = "notexist.yml"
      expect { settings.to_h }.to raise_error(EasySettings::SourceFileNotExist)
    end
  end
end
