require "hashie"

class EasySettings < Hashie::Mash
  VERSION = "0.0.1"

  class << self
    def method_missing(method_name, *args, &blk)
      p method_name
      p args
      instance.send(method_name, *args, &blk)
    end

    def instance
      @mash ||= new
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
