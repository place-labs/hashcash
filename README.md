# hashcash

Crystal Lang implemenation of [Hashcash](https://en.wikipedia.org/wiki/Hashcash) proof-of-work system.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     hashcash:
       github: place-labs/hashcash
   ```

2. Run `shards install`

## Usage

  ```crystal
  require "hashcash"
  ```
To generate a hashcash string:

  ```crystal
  Hashcash.generate("resource")
  # => "1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA=="
  ```

To verify a hashcash string:

  ``` crystal
  Hashcash.valid?("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource")
  # => true
  Hashcash.valid!("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource")
  # => "1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA=="
  # (or raises an exception if invalid)
  ```

## Contributing

1. Fork it (<https://github.com/your-github-user/hashcash/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Gab Fitzgerald](https://github.com/GabFitzgerald) - creator
- [Caspian Baska](https://github.com/caspiano) - maintainer
