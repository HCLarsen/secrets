class Any
  # All valid Secrets::Any types
  alias Type = String | Array(Any) | Hash(String, Any)

  # Creates an `Any` that wraps the given `Type`.
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

  # Checks that the underlying value is `String`, and returns its value.
  # Raises otherwise.
  def as_s : String
    @raw.as(String)
  end

  # Checks that the underlying value is `Array(String)`, and returns its value.
  # Raises otherwise.
  def as_a : Array(String)
    @raw.as(Array).map { |e| e.as_s }
  end

  # Checks that the underlying value is `Hash(String, String)`, and returns its value.
  # Raises otherwise.
  def as_h : Hash(String, String)
    keys = @raw.as(Hash).keys
    values = @raw.as(Hash).values.map do |e|
      if e.is_a? Any
        e.as_s
      else
        e
      end
    end
    Hash.zip(keys, values)
  end
end
