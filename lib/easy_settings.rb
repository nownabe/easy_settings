require "hashie"
require "yaml"
require "erb"

require "easy_settings_version"

class EasySettings < Hashie::Mash
  include EasySettingsVersion

  class SourceFileNotExist < StandardError; end

  DEFAULT_FILES = %w(settings.yml config/settings.yml)

  class << self
    attr_accessor :source_hash, :source_file, :namespace

    def instance
      @instance ||= new(namespace ? _source[namespace] : _source)
    end

    def load!
      instance
      true
    end

    def reload!
      @instance = nil
      load!
    end

    def [](key)
      instance[key]
    end

    def []=(key, val)
      instance[key] = val
    end

    private

    def _source
      return source_hash.to_hash if source_hash
      return _source_from_file if source_file
      _source_from_default_file
    end

    def _load_file(file)
      content = File.read(file)
      content.empty? ? nil : YAML.load(ERB.new(content).result).to_hash
    end

    def _source_from_file
      unless FileTest.exist?(source_file)
        raise(SourceFileNotExist, "Your source file '#{file}' does not exist.")
      end
      _load_file(source_file)
    end

    def _source_from_default_file
      DEFAULT_FILES.each do |f|
        path = File.expand_path(f, Dir.pwd)
        return _load_file(path) if FileTest.exist?(path)
      end
      nil
    end

    def method_missing(method_name, *args, &blk)
      instance.send(method_name, *args, &blk)
    end
  end

  def assign_property(name, value)
    super
    self[name]
  end

  def method_missing(method_name, *args, &blk)
    return self.[](method_name, &blk) if key?(method_name)
    name, suffix = method_suffix(method_name)
    case suffix
    when '='
      assign_property(name, args.first)
    when '?'
      !!self[name]
    when '!'
      initializing_reader(name)
    when '_'
      underbang_reader(name)
    else
      if !args[0].nil? or (args[1] and args[1][:nil])
        assign_property(name, args.first)
      else
        self[method_name]
      end
    end
  end
end
