# secrets.cr

Encrypted credentials management system, largely based on [Rails/secrets](https://github.com/rails/rails/blob/3a69bcdf1fff15234410a598617767203ab38eae/railties/lib/rails/secrets.rb)

## Shard

### Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     secrets:
       github: HCLarsen/secrets
   ```

2. Run `shards install`

### Usage

The `Secrets` class has two initializers, `#load` to load secrets from an existing secrets file, and `#new`, to create a new file to load programmatically. If `#new` is used, and the specified secrets file already exists, then an error will be thrown. As `#new` is starting from scratch, it does allow for a hash literal to be passed in the creation.

```ruby
require "secrets"

secrets = Secrets.new{ "API1_KEY" => "RANDOM_KEY", "API2_KEY" => "OTHER_RANDOM_KEY" }
```

Unlike similar libraries, the `Secrets` class isn't a singleton. This allows the dev to have separate files for different environments, such as development, testing, and production.

If unspecified, the default name for the secrets file is `secrets.yml.enc`, and the location is the current directory. If a specific name/location are required, then they can be specified during the initialization:

```ruby
require "secrets"

secrets = Secrets.new("./config/production.yml.enc")
```

OR:

```ruby
require "secrets"

secrets = Secrets.load("./config/production.yml.enc")
```

Secrets are presented as a `Hash` of type `String => YAML::Any`.

```ruby
require "secrets"

secrets = Secrets.load
secrets["API_KEY"].as_s           #=> "RANDOM_KEY"

secrets["API2"]["EMAIL"].as_s     #=> "random@example.org"
secrets["API2"]["PASSWORD"].as_s  #=> "DontUseACommonPassword"
```

## CLI

### Installation

1. Clone this repo:

   ```
   git clone https://github.com/HCLarsen/secrets.git
   ```

2. Build:
   ```
   make build-cli
   ```

3. Move `secrets` file to a location in your $PATH.

### Usage

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/HCLarsen/secrets/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Larsen](https://github.com/HCLarsen) - creator and maintainer
