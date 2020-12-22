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
end
