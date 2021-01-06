require "minitest/autorun"

require "/../src/secrets.cr"

class SecretsTest < Minitest::Test
  @default_path = "secrets.yml.enc"
  @default_key_path = "secrets.key"

  def setup
    if File.exists?(".gitignore")
      File.copy(".gitignore", ".gitignore-main")
    end
  end

  def teardown
    File.delete(@default_path) if File.exists?(@default_path)
    File.delete(@default_key_path) if File.exists?(@default_key_path)

    if File.exists?(".gitignore-main")
      File.rename(".gitignore-main", ".gitignore")
    end
  end

  def test_initializes_with_default_paths
    secrets = Secrets.new
    assert_equal @default_path, secrets.file_path
    assert_equal @default_key_path, secrets.key_path
  end

  def test_initializes_with_custom_paths
    secrets = Secrets.new("config/credentials.yml.enc", "config/master.key")
    assert_equal "config/credentials.yml.enc", secrets.file_path
    assert_equal "config/master.key", secrets.key_path
  end

  def test_adds_file_extension_if_not_provided
    secrets = Secrets.new("config/credentials", "config/master")
    assert_equal "config/credentials.yml.enc", secrets.file_path
    assert_equal "config/master.key", secrets.key_path
  end

  def test_initializes_hashlike
    secrets = Secrets{ "username" => "warmachine68@starkindustries.com", "password" => "WARMACHINEROX" }
    assert_equal "WARMACHINEROX", secrets["password"].as_s
  end

  def test_nested_values
    secrets = Secrets.new
    secrets["login"] = { "username" => Any.new("warmachine68@starkindustries.com"), "password" => Any.new("WARMACHINEROX") }

    expected = { "username" => "warmachine68@starkindustries.com", "password" => "WARMACHINEROX" }
    assert_equal expected, secrets["login"].as_h
    assert_equal "warmachine68@starkindustries.com", secrets["login"]["username"].as_s
  end

  def test_raises_for_invalid_filename
  end

  def test_generates_default_files
    Secrets.generate

    assert File.exists?(@default_path)
    assert File.exists?(@default_key_path)

    key = File.read(@default_key_path)
    assert_match /[\w\d]+/, key
  end

  def test_generates_custom_files
    Dir.mkdir_p("config")
    Secrets.generate("config/credentials.yml.enc", "config/master.key")

    assert File.exists?("config/credentials.yml.enc")
    assert File.exists?("config/master.key")

    key = File.read("config/master.key")
    assert_match /[\w\d]+/, key

    # Clean up
    File.delete("config/credentials.yml.enc") if File.exists?("config/credentials.yml.enc")
    File.delete("config/master.key") if File.exists?("config/master.key")
    Dir.delete("config") if Dir.exists?("config")
  end

  def test_modifies_gitignore_file
    File.touch(".gitignore")

    Secrets.generate

    gitignore = File.read(".gitignore")
    assert_match /#{@default_key_path}/, gitignore
  end
end
