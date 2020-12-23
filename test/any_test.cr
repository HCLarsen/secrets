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

  # def test_parses_yaml
  # end
end
