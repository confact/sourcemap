# Sourcemap Parser

A sourcemap parser in crystal, using vlq encoding.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     sourcemap:
       github: confact/sourcemap
   ```

2. Run `shards install`

## Usage

```crystal
require "sourcemap"
```

Get a sourcemap from a sourcemap file:

```crystal
Sourcemap::Parser.from_file("sourcemap.js.map")
```

Get a sourcemap from a sourcemap json string:

```crystal
Sourcemap::Parser.from_string(sourcemap_string)
```

To get the mappings of the sourcemap:

```crystal
sourcemap = Sourcemap::Parser.from_file("sourcemap.js.map")

sourcemap.parsed_mappings
```

It will return an array of Sourcemap::Mapping. Those mappings can be used to get the original source code and the original line and column.


## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/sourcemap_parser/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Håkan](https://github.com/your-github-user) - creator and maintainer
