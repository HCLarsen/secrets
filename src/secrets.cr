require "openssl"
require "./any"

# TODO: Write documentation for `Secrets`
class Secrets
  VERSION = "0.1.0"

  getter file_path : String
  getter key_path : String
  @data = Any.new({} of String => Any)

  def initialize(file_path = "secrets.yml.enc", key_path = "secrets.key")
    @file_path = Secrets.path_with_extension(file_path)
    @key_path = Secrets.key_path_with_extension(key_path)
  end

  # Generates the encrypted file and key file.
  #
  # If this command is run from the same directory as the `gitignore` file, it
  # will also read the file, and add the key file to it if necessary.
  #
  def self.generate(path = "secrets.yml.enc", key_path = "secrets.key")
    File.new(path_with_extension(path), "w")
    key = Secrets.generate_key
    File.write(key_path_with_extension(key_path), key)

    if File.exists?(".gitignore")
      ignore_content = key_path_with_extension(key_path)
      unless File.read(".gitignore").includes?(ignore_content)
        File.write(".gitignore", ignore_content, mode: "a")
      end
    end
  end

  delegate :[], to: @data
  delegate :[]=, to: @data

  protected def self.path_with_extension(path : String) : String
    extension = ".yml.enc"
    if path.ends_with? extension
      path
    else
      path + extension
    end
  end

  protected def self.key_path_with_extension(path : String) : String
    extension = ".key"
    if path.ends_with? extension
      path
    else
      path + extension
    end
  end

  protected def self.generate_key
    cipher = new_cipher
    Random::Secure.hex(cipher.key_len)[0, cipher.key_len]
  end

  private def self.new_cipher
    OpenSSL::Cipher.new("aes-256-cbc")
  end
end
