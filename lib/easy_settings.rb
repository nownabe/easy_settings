require "hashie"
require "yaml"
require "erb"

class EasySettings < Hashie::Mash
  VERSION = "0.0.1"

  class << self
    attr_accessor :source_hash, :source_file, :namespace

    def method_missing(method_name, *args, &blk)
      p method_name
      p args
      instance.send(method_name, *args, &blk)
    end

    def instance
      @instance ||= new(source_hash || source_file, nil, namespace)
    end

    def load!
      instance
      true
    end

    def reload!
      @instance = nil
      load!
    end
  end

  def initialize(source = nil, default = nil, namespace = nil, &blk)
    source = load_source_file(source) if source.nil? or source.is_a?(String)
    source = source[namespace] if namespace
    super(source, default)
  end

  def assign_property(name, value)
    super
    self[name]
  end

  def find_file(file)
    return file if file and FileTest.exist?(file)
    ["settings.yml", "config/settings.yml"].each do |f|
      path = File.expand_path(f, Dir.pwd)
      return path if FileTest.exist?(path)
    end
    nil
  end

  def load_source_file(source)
    file = find_file(source)
    return nil unless file # = find_file(source)
    content = File.read(file)
    content.empty? ? {} : YAML.load(ERB.new(content).result).to_hash
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
