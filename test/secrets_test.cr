require "minitest/autorun"

require "/../src/secrets.cr"

class SecretsTest < Minitest::Test
  def test_initializes_new_secrets_object
    secrets = Secrets.new
    assert_equal "secrets.yml.enc", secrets.filepath
  end

  def test_initializes_with_custom_path
    secrets = Secrets.new("configs/credentials.yml.enc")
    assert_equal "configs/credentials.yml.enc", secrets.filepath
  end

  def test_adds_file_extension_if_not_provided
    secrets = Secrets.new("configs/credentials")
    assert_equal "configs/credentials.yml.enc", secrets.filepath
  end
  
  def test_initializes_hashlike
  end

  def test_raises_for_invalid_filename
  end
end
