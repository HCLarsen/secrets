require "yaml"

# Secrets::Any is a wrapper around the possible types stored in a `Secrets`
# object, similar to`YAML::Any`.
#
# Unlike its counterpart, `Secrets::Any` is a mutible structure, allowing the
# underlying value to be changed, as long as the new value is of the same type.
# The other key difference from `YAML::Any` is that the leaf values can only
# be a `String`.
class Secrets
  struct Any
    # All valid Secrets::Any types
    alias Type = String | Array(Any) | Hash(String, Any)

    # The raw underlying value, a `Type`.
    getter raw : Type

    # Creates an `Any` that wraps the given `Type`.
    #
    def initialize(@raw : Type)
    end

    # Creates an `Any` that wraps the given `Array` of Strings.
    def initialize(array : Array(String))
      @raw = array.map { |e| Any.new(e) }
    end

    # Creates an `Any` that wraps the given `Hash` of Strings.
    def initialize(hash : Hash(String, String))
      keys = hash.keys
      values = hash.values.map { |e| Any.new(e) }
      @raw = Hash.zip(keys, values)
    end

    # Creates an `Any` from the raw value of a `YAML::Any`.
    def initialize(any : YAML::Any)
      value = any.raw
      case value
      when Hash
        raw = {} of String => Any
        value.each do |k, v|
          raw[k.as_s] = Any.new(v)
        end
        @raw = raw
      when String
        @raw = value
      else
        raise "Unusable type: #{value.class}. Requires String, Array(String), or Hash(String, String)"
      end
    end

    # Assumes the underlying value is an `Array` or `Hash`
    # and returns the element at the given *index_or_key*.
    #
    # Raises if the underlying value is not an `Array` nor a `Hash`.
    def [](index_or_key : Int32 | String) : Any
      case object = @raw
      when Array
        if index_or_key.is_a?(Int)
          object[index_or_key]
        else
          raise "Expected int key for Array#[], not #{object.class}"
        end
      when Hash
        if index_or_key.is_a?(String)
          object[index_or_key]
        else
          raise "Expected string key for Hash#[], not #{object.class}"
        end
      else
        raise "Expected Array or Hash, not #{object.class}"
      end
    end

    # Assumes the underlying value is an `Array` or `Hash` and returns the element
    # at the given *index_or_key*, or `nil` if out of bounds or the key is missing.
    #
    # Raises if the underlying value is not an `Array` nor a `Hash`.
    def []?(index_or_key : Int32 | String) : Any?
      case object = @raw
      when Array
        if index_or_key.is_a?(Int)
          object[index_or_key]?
        else
          raise "Expected int key for Array#[], not #{object.class}"
        end
      when Hash
        if index_or_key.is_a?(String)
          object[index_or_key]?
        else
          raise "Expected string key for Hash#[], not #{object.class}"
        end
      else
        raise "Expected Array or Hash, not #{object.class}"
      end
    end

    # Assumes the underlying value is an `Array` or `Hash`
    # and assigns a value at the given *index_or_key*.
    #
    # Raises if the underlying value is not an `Array` nor a `Hash`.
    def []=(index_or_key : Int32 | String, value : Type)
      case object = @raw
      when Array
        if index_or_key.is_a?(Int)
          object[index_or_key] = Any.new(value)
        else
          raise "Expected int key for Array#[], not #{object.class}"
        end
      when Hash
        if index_or_key.is_a?(String)
          object[index_or_key] = Any.new(value)
        end
      end
    end

    # Checks that the underlying value is `String`, and returns its value.
    # Raises otherwise.
    def as_s : String
      @raw.as(String)
    end

    # Checks that the underlying value is `String`, and returns its value.
    # Returns `nil` otherwise.
    def as_s? : String?
      @raw.as?(String)
    end

    # Checks that the underlying value is `Array(String)`, and returns its value.
    # Raises otherwise.
    def as_a : Array(String)
      @raw.as(Array).map { |e| e.as_s }
    end

    # Checks that the underlying value is `Array(String)`, and returns its value.
    # Returns `nil` otherwise.
    def as_a? : Array(String)?
      @raw.is_a?(Array) ? self.as_a : nil
    end

    # Checks that the underlying value is `Hash(String, String)`, and returns its value.
    # Raises otherwise.
    def as_h : Hash(String, String)
      keys = @raw.as(Hash).keys
      values = @raw.as(Hash).values.map do |e|
        e.as_s
      end
      Hash.zip(keys, values)
    end

    # Checks that the underlying value is `Hash(String, String)`, and returns its value.
    # Returns `nil` otherwise.
    def as_h? : Hash(String, String)?
      @raw.is_a?(Hash) ? self.as_h : nil
    end

    def self.from_yaml(yaml : String) : Any
      parsed = YAML.parse(yaml)
      if !parsed.raw.nil?
        Any.new(parsed)
      else
        Any.new({} of String => Any)
      end
    end

    def to_yaml(yaml : YAML::Nodes::Builder)
      @raw.to_yaml(yaml)
    end
  end
end
