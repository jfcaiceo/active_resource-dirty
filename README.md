# ActiveResource::Dirty
`ActiveResource::Dirty` is a monkey patch that supports `ActiveModel::Dirty` methods in `ActiveResource`.

## Usage
Provides a way to track changes in your object. For example:
```ruby
person = Person.find(1)
person.changed?         # => false
person.name = 'Frank'
person.changes          # => {"name"=>[nil, 'Frank']}
person.name_was         # nil
person.save
person.changes          # => {}
person.previous_changes # => {"name"=>[nil, 'Frank']}
```

### PATCH Requests
It uses the http `PATCH` method instead of `PUT`, and sends in the body only the attributes that have changed. This feature requires the flag `patch_updates`.
```ruby
class Person < ActiveResource::Base
  self.site = 'http://someapi.com'
  self.patch_updates = true
end
```

```ruby
person = Person.find(1)
person.name = 'Frank'
person.save
# Sends this request:
# PATCH http://someapi.com/people/1.json
# {"name":"Frank"}
#
```
## Considerations
This is a monkey patch that overrides methods from both `ActiveResource` and `ActiveModel::Dirty` (the latter one only for ActiveResource::Base. It does not affect `ActiveModel` for other uses). Any change in this methods in future versions can lead to unexpected results. So use with caution.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'active_resource-dirty'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install active_resource-dirty
```

## Requirements
* activemodel ~> 5.2.0
* activeresource ~> 5.1.0
* activesupport ~> 5.2.0

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
