# secrets.cr

**DO NOT USE - BREAKING CHANGES MAY STILL COME**

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

When the `Secrets` class is instantiated, it loads the data from an encoded YAML file. The key used to decode the data can either come from a local key file, or an environment variable named SECRETS_KEY.

```ruby
require "secrets"

secrets = Secrets.new
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

The Secrets cli provides a way to create, edit, and read encrypted Secrets files.

The `secrets generate` command creates an empty encrypted Secrets file, and a key file. The default location is the folder that the command is run from, however the `-p` and `-k` flags can be used to set specific locations for the Secrets file and key file, respectively.

```
$ secrets generate -p production.yml.enc -k keyfile.key
```

`secrets read` will read the Secrets file and display the contents to the command line. If an optional `--key` value is provided, it will only display the value that corresponds to that key. As with the `generate` command, `-p` and `-k` flags can be used to specify locations for the files.

```
$ secrets read --key API_KEY
```

`secrets edit` requires a key value pair provided as arguments. If they key already exists in the file, it will edit the value with the one provided, otherwise, it will add the key value pair as new entries.

```
$ secrets edit API_KEY NOTAREALKEY
```

`secrets reset` generates a new key, and re-encrypts the file with the new key. As with the `generate` command, `-p` and `-k` flags can be used to specify locations for the files.

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
