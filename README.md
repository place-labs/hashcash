# hashcash

TODO: Write a description here

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
Hashcash.generate("resource") # => "1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA=="
```

To verify a hashcash string:

``` crystal
Hashcash.verify?("1:20:201206222555:resource::pOWgc88+uDuefr/o:MTMxNzg2MA==", "resource") # => true
```


TODO: Write complete usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/hashcash/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [GabFitzgerald](https://github.com/GabFitzgerald) - creator and maintainer
