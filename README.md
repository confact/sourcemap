# Sourcemap Parser

A sourcemap parser in crystal, using vlq encoding.

This repo use changed code from the repo [ConradIrwin/ruby-source_map](https://github.com/ConradIrwin/ruby-source_map). Thanks Conrad Irwin!

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


Retrive all mappings for a line and column:

```crystal
sourcemap = Sourcemap::Parser.from_file("sourcemap.js.map")

mapping = sourcemap.mapping_for(1, 1)
```

Get mappings for specific source file:

```crystal
sourcemap = Sourcemap::Parser.from_file("sourcemap.js.map")

sourcemap.mappings_for_source("sourcemap.js")
```


## Development

clone the repo and see the code and test the specs. the specs can be run with `crystal spec`

## Contributing

1. Fork it (<https://github.com/confact/sourcemap/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Håkan](https://github.com/confact) - creator and maintainer
