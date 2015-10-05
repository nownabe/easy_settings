describe EasySettings do
  RAILS_ROOT = File.expand_path("../easy_settings_test", __FILE__)

  def run_rails_spec
    Bundler.with_clean_env do
      pid = spawn("cd #{RAILS_ROOT} && bundle exec rspec")
      Process.waitpid2(pid).last.exitstatus
    end
  end

  it { expect(run_rails_spec).to eq 0 }
end
