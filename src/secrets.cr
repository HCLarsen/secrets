require "openssl"
require "./any"

# The Secrets class keeps track of a YAML-like structure of secrets for an
# application, and is responsible for encrypting and decrypting the file where
# those secrets are stored.
#
# Note: Whenever any change is made to the data in the Secrets object, it will
# save the data to the file. This not only results in the secrets data being
# saved in the event of the app crashing.
#
class Secrets
  VERSION = "0.1.0"

  class MissingKeyError < RuntimeError
    def initialize
      super <<-end_of_message
        Missing encryption key to decrypt secrets with.
        Ask your team for your master key and put it in ENV["SECRETS_KEY"]
      end_of_message
    end
  end

  getter file_path : String
  @key : String
  @data : Any

  # Initializes a new `Secrets` object, and loads it from the encrypted YAML
  # file at the specified location.
  #
  # Raises a File::NotFoundError if the specified secrets file doesn't exist.
  #
  def initialize(file_path = "secrets.yml.enc", key_path = "secrets.key")
    @file_path = Secrets.path_with_extension(file_path)
    @key = load_key(Secrets.key_path_with_extension(key_path))

    @data = load_data
  end

  # Generates an encrypted secrets file and key file at the specified locations,
  # overwriting the files if they already exist.
  #
  # If this command is run from the same directory as the `gitignore` file, it
  # will also read the file, and add the key file to it if necessary.
  #
  # Note: This command won't create any folders required, and will throw a
  # NotFoundError if the folder doesn't exist.
  #
  def self.generate(path = "secrets.yml.enc", key_path = "secrets.key")
    file_path = path_with_extension(path)
    key_file_path = key_path_with_extension(key_path)

    key = Secrets.generate_key
    File.write(key_file_path, key)

    text = "# location: #{path}"
    cipher = Secrets.new_cipher
    cipher.encrypt
    cipher.key = key
    encrypted = String.new(cipher.update(text)) + String.new(cipher.final)

    File.write(file_path, encrypted)

    if File.exists?(".gitignore")
      ignore_content = key_path_with_extension(key_path)
      unless File.read(".gitignore").includes?(ignore_content)
        File.write(".gitignore", ignore_content, mode: "a")
      end
    end
  end

  # Generates an encrypted secrets file and key file at the specified locations,
  # raising an error if the files already exist.
  #
  # If this command is run from the same directory as the `gitignore` file, it
  # will also read the file, and add the key file to it if necessary.
  #
  # Note: As with the standard `generate` method, this command won't create
  # any folders required, and will throw a NotFoundError if the folder doesn't
  # exist.
  def self.generate!(path = "secrets.yml.enc", key_path = "secrets.key")
    file_path = path_with_extension(path)
    key_file_path = key_path_with_extension(key_path)
    raise File::AlreadyExistsError.new("Secrets file already exists", file: file_path) if File.exists?(file_path)
    raise File::AlreadyExistsError.new("Key file already exists", file: key_file_path) if File.exists?(key_file_path)

    generate(file_path, key_file_path)
  end

  # Returns the value for the key given by *key*.
  # If not found, returns the default value given by `Hash.new`, otherwise
  # raises `KeyError`.
  delegate :[], to: @data

  # Sets the value of *key* to the given *value*.
  #
  # **Note:** This method results in the new value not only being stored in
  # the `Secrets` object, but also saved to the *secrets* file.
  def []=(index_or_key : Int32 | String, value : Any::Type)
    @data[index_or_key] = value

    # encrypted = encrypt(@data.to_yaml)
    # File.write(@file_path, encrypted)
    save
  end

  # Saves data to the secrets file.
  def save
    encrypted = encrypt(@data.to_yaml)
    File.write(@file_path, encrypted)
  end

  # Loads the YAML data from the encrypted secrets file.
  def load_data : Any
    encrypted = File.read(@file_path)
    decrypted = decrypt(encrypted)
    Any.from_yaml(decrypted)
  end

  # Encrypts *data* using the object's key and returns the encrypted data as
  # a `String`.
  def encrypt(data : String) : String
    cipher = Secrets.new_cipher
    cipher.encrypt
    cipher.key = @key
    String.new(cipher.update(data)) + String.new(cipher.final)
  end

  # Decrypts *data* using the key and returns the decrypted data as a `String`.
  def decrypt(data : String) : String
    decipher = Secrets.new_cipher
    decipher.decrypt
    decipher.key = @key
    String.new(decipher.update(data)) + String.new(decipher.final)
  end

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

  protected def self.generate_key : String
    cipher = new_cipher
    Random::Secure.hex(cipher.key_len)[0, cipher.key_len]
  end

  protected def self.new_cipher : OpenSSL::Cipher
    OpenSSL::Cipher.new("aes-256-cbc")
  end

  private def load_key(key_path : String) : String
    ENV["SECRETS_KEY"]? || read_key_file(key_path) || handle_missing_key
  end

  private def handle_missing_key
    raise Secrets::MissingKeyError.new
  end

  private def read_key_file(key_path : String) : String?
    if File.exists?(key_path)
      File.read(key_path)
    end
  end
end
