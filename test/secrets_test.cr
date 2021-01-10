require "minitest/autorun"

require "/../src/secrets.cr"

class MySecrets
  include YAML::Serializable

  property username : String
  property password : String
end

class SecretsTest < Minitest::Test
  @default_path = "secrets.yml.enc"
  @default_key_path = "secrets.key"

  def setup
    Dir.mkdir_p("config")

    if File.exists?(".gitignore")
      File.copy(".gitignore", ".gitignore-main")
    end
  end

  def teardown
    File.delete(@default_path) if File.exists?(@default_path)
    File.delete(@default_key_path) if File.exists?(@default_key_path)

    File.delete("config/credentials.yml.enc") if File.exists?("config/credentials.yml.enc")
    File.delete("config/master.key") if File.exists?("config/master.key")
    Dir.delete("config") if Dir.exists?("config")

    if File.exists?(".gitignore-main")
      File.rename(".gitignore-main", ".gitignore")
    end
  end

  def generate_secrets
    Secrets.generate

    secrets = Secrets.new
    secrets["username"] = "warmachine68@starkindustries.com"
    secrets["password"] = "WARMACHINEROX"

    secrets.save
  end

  def test_initializes_with_default_paths
    Secrets.generate

    secrets = Secrets.new
    assert_equal @default_path, secrets.file_path
  end

  def test_initializes_with_custom_paths
    Secrets.generate("config/credentials.yml.enc", "config/master.key")

    secrets = Secrets.new("config/credentials.yml.enc", "config/master.key")
    assert_equal "config/credentials.yml.enc", secrets.file_path
  end

  def test_adds_file_extension_if_not_provided
    Secrets.generate("config/credentials", "config/master")

    secrets = Secrets.new("config/credentials", "config/master")
    assert_equal "config/credentials.yml.enc", secrets.file_path
  end

  def test_encrypts_and_decrypts
    username = "warmachine68@starkindustries.com"
    Secrets.generate

    secrets = Secrets.new
    secrets["username"] = username
    secrets.save

    saved = File.read(@default_path)

    refute saved.includes?(username)

    secrets2 = Secrets.new
    assert_equal username, secrets2["username"].as_s
  end

  def test_nested_values
    Secrets.generate
    expected = {"username" => "warmachine68@starkindustries.com", "password" => "WARMACHINEROX"}

    secrets = Secrets.new
    secrets["login"] = {"username" => Secrets::Any.new("warmachine68@starkindustries.com"), "password" => Secrets::Any.new("WARMACHINEROX")}
    secrets.save

    assert_equal expected, secrets["login"].as_h
    assert_equal "warmachine68@starkindustries.com", secrets["login"]["username"].as_s
  end

  def test_generates_default_files
    Secrets.generate

    assert File.exists?(@default_path)
    assert File.exists?(@default_key_path)

    key = File.read(@default_key_path)
    assert_match /[\w\d]+/, key
  end

  def test_generate_bang_raises_if_file_exists
    Secrets.generate

    error = assert_raises do
      Secrets.generate!
    end
    assert_equal File::AlreadyExistsError, error.class
    assert_equal "Secrets file already exists", error.message

    File.delete(@default_path)

    error = assert_raises do
      Secrets.generate!
    end
    assert_equal File::AlreadyExistsError, error.class
    assert_equal "Key file already exists", error.message
  end

  def test_modifies_gitignore_file
    File.touch(".gitignore")

    Secrets.generate

    gitignore = File.read(".gitignore")
    assert_match /#{@default_key_path}/, gitignore
  end

  def test_raises_when_reading_secrets_without_a_key
    Secrets.generate
    File.delete(@default_key_path)

    error = assert_raises do
      Secrets.new
    end
    assert_equal Secrets::MissingKeyError, error.class
  end

  def test_reading_with_env_variable
    generate_secrets

    ENV["SECRETS_KEY"] = File.read(@default_key_path)
    File.delete(@default_key_path)

    secrets = Secrets.new
    assert_equal "WARMACHINEROX", secrets["password"].as_s

    ENV.delete("SECRETS_KEY")
  end

  def test_generates_saves_and_loads_custom_files
    Secrets.generate("config/credentials.yml.enc", "config/master.key")
    assert File.exists?("config/credentials.yml.enc")
    assert File.exists?("config/master.key")

    secrets = Secrets.new("config/credentials.yml.enc", "config/master.key")
    secrets["login"] = {"username" => Secrets::Any.new("warmachine68@starkindustries.com"), "password" => Secrets::Any.new("WARMACHINEROX")}
    secrets.save

    secrets2 = Secrets.new("config/credentials.yml.enc", "config/master.key")
    assert_equal "warmachine68@starkindustries.com", secrets2["login"]["username"].as_s
  end

  def test_produces_raw_yaml
    expected = "---\nusername: warmachine68@starkindustries.com\npassword: WARMACHINEROX\n"

    generate_secrets

    secrets = Secrets.new
    assert_equal expected, secrets.raw

    my_secrets = MySecrets.from_yaml(secrets.raw)
    assert_equal "WARMACHINEROX", my_secrets.password
  end
end
