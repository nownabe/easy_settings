# EasySettings
[![Gem Version](https://badge.fury.io/rb/easy_settings.svg)](http://badge.fury.io/rb/easy_settings)
[![Code Climate](https://codeclimate.com/github/nownabe/easy_settings/badges/gpa.svg)](https://codeclimate.com/github/nownabe/easy_settings)
[![Test Coverage](https://codeclimate.com/github/nownabe/easy_settings/badges/coverage.svg)](https://codeclimate.com/github/nownabe/easy_settings)
[![Build Status](https://travis-ci.org/nownabe/easy_settings.svg)](https://travis-ci.org/nownabe/easy_settings)

EasySettings is a simple manager of setting constants.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_settings'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_settings

## Usage
EasySettings can load YAML file and understand ERB format.

### Basic usage
Most simple usage is to put your settings file `settings.yml` to your application's directory.

`settings.yml` or `config/settings.yml`:

```yaml
log_level: info
other_service:
  endpoint: https://myapp/api/v1
  apikey: API_KEY_XXX
  secret: SECRET_KEY_XXX
demo_users:
  <% 5.times do |i| %>
  - <%= "user%02d" % [i] %>
  <% end %>
```

And you can use EasySettings constant in your application:

```ruby
require "easy_settings"

EasySettings.log_level #=> "info"
```

EasySettings hash can be used with method style, string keys and symbol keys:

```ruby
EasySettings.log_level    #=> "info"
EasySettings["log_level"] #=> "info"
EasySettings[:log_level]  #=> "info"
```

EasySettings can treat nested hash:

```ruby
EasySettings.other_service
#=> {"endpoint"=>"https://myapp/api/v1", "apikey"=>"API_KEY_XXX", "secret"=>"SECRET_KEY_XXX"}

EasySettings.other_service.endpoint    #=> "https://myapp/api/v1"
EasySettings.other_service["endpoint"] #=> "https://myapp/api/v1"
EasySettings.other_service[:endpoint]  #=> "https://myapp/api/v1"
```

EasySettings process ERB format:

```ruby
EasySettings.demo_users
#=> ["user00", "user01", "user02", "user03", "user04"]
```

You can set values.

```ruby
EasySettings.app_name = "MyApp" #=> "MyApp"
EasySettings["app_name"]        #=> "MyApp"
EasySettings[:app_name]         #=> "MyApp"
```

If you want to use other settings file, you can use any other file with `EasySettings.source_file =`.

```ruby
EasySettings.source_file = Rails.root.join("config/application.yml").to_s
```

### Namespace
You can use EasySettings with namespace:

```yaml
defaults: &defaults
  app_name: NamespaceSample

development: &development
  <<: *defaults
  endpoint: http://backend-dev/api/v1

test:
  <<: *development

production:
  <<: *defaults
  endpoint: http://backend/api/v1
```

Using EasySettings with `namespace =`:

```ruby
Rails.env
#=> "production"

EasySettings.namespace = Rails.env
#=> "production"

EasySettings.app_name
#=> "NamespaceSample"

EasySettings.endpoint
#=> "http://backend/api/v1"
```

### Default value
You can set default value.
Default value will be set when EasySettings doesn't have value with the key yet.

```ruby
EasySettings.has_key?(:foo)
#=> false

EasySettings.foo
#=> nil

EasySettings.foo("bar")
#=> "bar"

EasySettings.foo
#=> "bar"

EasySettings.has_key?(:foo)
#=> true

EasySettings.foo("baz")
#=> "bar"
```

Using nil option, you can set nil:

```ruby
EasySettings.app_name(nil)
#=> nil
EasySettings.has_key?(:app_name)
#=> false

EasySettings.app_name(nil, nil: true)
#=> nil
EasySettings.has_key?(:app_name)
#=> true
```

And EasySettings can treat nested hash:

```ruby
EasySettings.other_service({}).endpoint = "https://default/"
#=> "https://default/"
EasySettings.to_h
#=> {"other_service"=>{"endpoint"=>"https://default/"}}
```

Or more simple:

```ruby
EasySettings.other_service!.endpoint = "https://default/"
```

### Reset EasySettings
```ruby
EasySettings.source_file = "new_settings.yml"
EasySettings.reload!

EasySettings.source_hash = {}
EasySettings.reload!
```

### Alias
```ruby
Config = EasySettings
Config.endpoint
```

Or using class that inherit EasySettings:

```ruby
class Config < EasySettings
  self.namespace = Rails.env
end

Config.endpoint
```

## With Rails
In your Gemfile:

```ruby
gem "easy_settings"
```

And write your settings in `config/settings.yml` with env:

```ruby
default: &default
  app_name: MyApp
  apikey: <%= ENV["APIKEY"] %>

development:
  <<: *default
  endpoint: https://endpoint-for-development

test:
  <<: *default
  endpoint: https://endpoint-for-test

production:
  <<: *default
  endpoint: https://endpoint-for-production
```

Then you can access EasySettings anywhere.

## Contributing

1. Fork it ( https://github.com/nownabe/easy_settings/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
