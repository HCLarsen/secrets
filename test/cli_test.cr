require "minitest/autorun"

require "/../src/cli.cr"

class CLITest < Minitest::Test
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
    secrets["login"] = {"username" => Secrets::Any.new("warmachine68@starkindustries.com"), "password" => Secrets::Any.new("WARMACHINEROX")}
    secrets.save
  end

  def test_generates_default_files
    `crystal run src/cli.cr -- generate`
    assert File.exists?(@default_path)
    assert File.exists?(@default_key_path)
  end

  def test_generates_with_custom_paths
    `crystal run src/cli.cr -- generate -y "config/credentials.yml.enc" -f config/master.key`
    assert File.exists?("config/credentials.yml.enc")
    assert File.exists?("config/master.key")
  end

  def test_reads_file
    generate_secrets

    expected = "---\nlogin:\n  username: warmachine68@starkindustries.com\n  password: WARMACHINEROX\n"
    response = `crystal run src/cli.cr -- read`

    assert_equal expected, response

    expected = "---\nusername: warmachine68@starkindustries.com\npassword: WARMACHINEROX\n"
    response = `crystal run src/cli.cr -- read -k login`

    assert_equal expected, response

    response = `crystal run src/cli.cr -- read -k login/password`

    assert_equal "WARMACHINEROX\n", response
  end

  def test_edits_file
    generate_secrets

    `crystal run src/cli.cr -- edit -k login/password -n TONYSTANK`

    response = `crystal run src/cli.cr -- read -k login/password`
    assert_equal "TONYSTANK\n", response

    `crystal run src/cli.cr -- edit -k a/b/c/d -n "Final Value"`

    response = `crystal run src/cli.cr -- read -k a/b/c/d`
    assert_equal "Final Value\n", response
  end

  def test_returns_version_number
    response = `crystal run src/cli.cr -- -v`
    assert_equal "0.1.0\n", response
  end

  def test_displays_help
  end
end
