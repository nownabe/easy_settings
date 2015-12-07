require "helpers/default_paths"

describe "inheritance" do
  include_context "default_paths"

  subject(:child_class1) do
    Class.new(settings) do
      self.default_files = [File.expand_path("../config/child1.yml", __FILE__)]
    end
  end

  let(:child_class2) do
    Class.new(settings) do
      self.default_files = [File.expand_path("../config/child2.yml", __FILE__)]
    end
  end
  before { FileUtils.cp test_settings_file, default_settings_path1 }
  after { FileUtils.rm default_settings_path1 }

  it "has different value from parent's one" do
    expect(child_class1.app_name).not_to eq EasySettings.app_name
  end

  it "has differnt value from other child class's one" do
    expect(child_class1.app_name).not_to eq child_class2.app_name
  end

  describe "grandchild" do
    subject(:grand_child) do
      Class.new(child_class1) do
        self.default_files = [File.expand_path("../config/grand_child.yml", __FILE__)]
      end
    end

    it "has different valud from child's one" do
      expect(grand_child.app_name).not_to eq child_class1.app_name
    end
  end
end
