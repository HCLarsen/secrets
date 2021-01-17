require "option_parser"

require "./secrets"

path = Secrets::DEFAULT_PATH
key_path = Secrets::DEFAULT_KEY_PATH
key = nil
value = nil

paths_parser = OptionParser.new do |parser|
  parser.on("-y PATH", "--yaml-file PATH", "File path") { |_path| path = _path }
  parser.on("-f KEY_PATH", "--key-file KEY_PATH", "Key file path") { |_key_path| key_path = _key_path }
end

key_parser = OptionParser.new do |parser|
  parser.on("-k KEY ", "--key KEY ", "Key for value") { |_key| key = _key }
end

value_parser = OptionParser.new do |parser|
  parser.on("-k KEY ", "--key KEY ", "Key for value") { |_key| key = _key }
  parser.on("-n NEWVALUE", "--new-value NEWVALUE", "New Value") { |_value| value = _value }
end

parser = OptionParser.new do |parser|
  parser.banner = "Usage: secrets [arguments]"
  parser.on("generate", "Create new secrets and key files") do
    paths_parser.banner = "Usage: secrets generate [arguments]"
    paths_parser.parse
    Secrets.generate(path, key_path)
  end
  parser.on("read", "Read the contents of the encrypted file") do
    key_parser.parse
    secrets = Secrets.new
    paths = key
    if paths
      parts = paths.split('/')
      any = secrets[parts.shift]
      parts.each do |part|
        any = any[part]
      end
      puts any.to_yaml.gsub("--- ", "")
    else
      puts secrets.raw
    end
    exit
  end
  parser.on("edit", "Edit a value in the encrypted file") do
    value_parser.parse
    secrets = Secrets.new
    paths = key
    new_value = value
    if paths && new_value
      parts = paths.split('/')
      first_key = parts.shift
      final_key = parts.pop
      unless secrets[first_key]?
        secrets[first_key] = {} of String => Secrets::Any
      end
      any = secrets[first_key]

      parts.each do |part|
        unless any[part]?
          any[part] = {} of String => Secrets::Any
        end
        any = any[part]
      end
      any[final_key] = new_value
      secrets.save
    else
      raise "Key/value path must be provided as an argument"
    end
    exit
  end
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.on("-v", "--version", "Returns version") { puts "0.1.0" }
end

parser.parse
