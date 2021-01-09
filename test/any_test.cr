require "minitest/autorun"

require "/../src/any.cr"

class AnyTest < Minitest::Test
  def test_initalizes_from_and_returns_raw_values
    string = "String"
    string_any = Any.new(string)
    assert_equal string, string_any.as_s

    array = ["First", "Second", "Third"]
    array_any = Any.new(array)
    assert_equal array, array_any.as_a

    hash = { "Hello" => "World" }
    hash_any = Any.new({ "Hello" => "World" })
    assert_equal hash, hash_any.as_h
  end

  def test_raises_error_for_misassigned_raw_values
    any = Any.new("String")
    error = assert_raises { any.as_a }
    assert_equal TypeCastError, error.class
    error = assert_raises { any.as_h }
    assert_equal TypeCastError, error.class

    any = Any.new(["First", "Second", "Third"])
    error = assert_raises { any.as_s }
    assert_equal TypeCastError, error.class
    error = assert_raises { any.as_h }
    assert_equal TypeCastError, error.class

    any = Any.new({ "Hello" => "World" })
    error = assert_raises { any.as_s }
    assert_equal TypeCastError, error.class
    error = assert_raises { any.as_a }
    assert_equal TypeCastError, error.class
  end

  def test_returns_nil_for_misassigned_raw_values
    any = Any.new("String")
    refute any.as_a?
    refute any.as_h?

    any = Any.new(["First", "Second", "Third"])
    refute any.as_s?
    refute any.as_h?

    any = Any.new({ "Hello" => "World" })
    refute any.as_s?
    refute any.as_a?
  end

  def test_returns_nested_hash_values
    hash = Any.new({ "Hello" => Any.new({"World" => "!"}) })
    assert_equal "!", hash["Hello"]["World"].as_s
  end

  def test_returns_nested_array_values
    array = Any.new([Any.new(["Hello", "World"]), Any.new(["Bonjour", "le monde"])])
    assert_equal "World", array[0][1].as_s
  end

  def test_assigns_nested_hash_values
    any = Any.new({"first" => "Hello"})
    any["second"] = {} of String => Any
    any["second"]["level"] = "World"

    assert_equal "World", any["second"]["level"].as_s
  end

  def test_assigns_nested_array_values
    array = Any.new([Any.new(["0", "1", "2"])])
    array[0][2] = "5"

    assert_equal "5", array[0][2].as_s
  end

  def test_parses_and_generates_yaml
    yaml = "---\nlogin:\n  username: warmachine68@starkindustries.com\n  password: WARMACHINEROX\n"

    any = Any.from_yaml(yaml)
    assert_equal "warmachine68@starkindustries.com", any["login"]["username"].as_s
    assert_equal "WARMACHINEROX", any["login"]["password"].as_s

    assert_equal yaml, any.to_yaml
  end

  def test_parses_empty_yaml
    yaml = "# Generated YAML file\n---"

    assert_equal Any.from_yaml(yaml).as_h, {} of String => Any
  end
end
