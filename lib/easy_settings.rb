require "hashie"
require "yaml"
require "erb"

class EasySettings < Hashie::Mash
  SourceFileNotExist = Class.new(StandardError)
  class << self
    attr_accessor :source_hash, :source_file, :namespace, :default_files

    def inherited(child_class)
      child_class.class_eval do
        define_singleton_method(:default_files) do
          instance_variable_get(:@default_files) || superclass.default_files
        end
      end
    end

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
        raise(SourceFileNotExist, "Your source file '#{source_file}' does not exist.")
      end
      _load_file(source_file)
    end

    def _source_from_default_file
      default_files.each do |f|
        path = File.expand_path(f, _root_path)
        return _load_file(path) if FileTest.exist?(path)
      end
      {}
    end

    def _root_path
      Dir.pwd
    end

    def method_missing(method_name, *args, &blk)
      instance.send(method_name, *args, &blk)
    end
  end

  self.default_files = %w(settings.yml config/settings.yml)

  def assign_property(name, value)
    super
    self[name]
  end

  def method_missing(method_name, *args, &blk)
    return self.[](method_name, &blk) if key?(method_name)
    name, suffix = method_name_and_suffix(method_name)
    case suffix
    when "="
      assign_property(name, args.first)
    when "?"
      !!self[name]
    when "!"
      initializing_reader(name)
    when "_"
      underbang_reader(name)
    else
      if !args[0].nil? || (args[1] && args[1][:nil])
        assign_property(name, args.first)
      else
        self[method_name]
      end
    end
  end
end

if Object.const_defined?(:Rails)
  require "easy_settings/rails"
end
