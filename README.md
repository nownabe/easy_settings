# EasySettings [![Gem Version](https://badge.fury.io/rb/easy_settings.svg)](http://badge.fury.io/rb/easy_settings) [![Code Climate](https://codeclimate.com/github/nownabe/easy_settings/badges/gpa.svg)](https://codeclimate.com/github/nownabe/easy_settings) [![Test Coverage](https://codeclimate.com/github/nownabe/easy_settings/badges/coverage.svg)](https://codeclimate.com/github/nownabe/easy_settings) [![Build Status](https://travis-ci.org/nownabe/easy_settings.svg?branch=ci)](https://travis-ci.org/nownabe/easy_settings)
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
Most simple usage is to put your settings file `settings.yml` to your application's root directory.

`settings.yml` or `config/settings.yml`:

```yaml
app_name: EasySettingsSample
users:
  nownabe:
    gender: male
    like: ["Angra", "Helloween", "SEX MACHINEGUNS", "μ's"]
timestamp: <%= Time.now.to_s %>
```

And your application can use EasySettings:

```ruby
require "easy_settings"

EasySettings.app_name    #=> "EasySettingsSample"
EasySettings["app_name"] #=> "EasySettingsSample"
EasySettings[:app_name]  #=> "EasySettingsSample"

EasySettings.users
#=> {"nownabe"=>{"gender"=>"male", "like"=>["Angra", "Helloween", "SEX MACHINEGUNS", "μ's"]}}
EasySettings.users[:nownabe][:gender]
#=> "male"
EasySettings.users.nownabe.like
#=> ["Angra", "Helloween", "SEX MACHINEGUNS", "μ's"]

EasySettings.timestamp
#=> 2015-03-07 00:11:28 +0900
```

You can set value to any key.

```ruby
EasySettings.app_name = "MyApp" #=> "MyApp"
EasySettings["app_name"]        #=> "MyApp"
EasySettings[:app_name]         #=> "MyApp"

EasySettings["app_name"] = "MyApp2" #=> "MyApp2"
EasySettings.app_name               #=> "MyApp2"
EasySettings[:app_name]             #=> "MyApp2"
```

If you want to use other settings file, you can use any other file with `EasySettings.source_file =`.

```ruby
EasySettings.source_file = Rails.root.join("config/application.yml").to_s
```

### Namespace
You can use namespace.

Settings YAML file:

```yaml
defaults: &defaults
  app_name: NamespaceSample
  endpoint: http://backend-dev/api/v1

development:
  <<: *defaults
  apikey: DEVFOOBAR123
  secret: DEVBAZQUX789

production:
  <<: *defaults
  endpoint: http://backend/api/v1
  apikey: PRDFOOBAR123
  secret: PRDBAZQUX789
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
Default value will be set with key when EasySettings doesn't have key.

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
EasySettings.users({}).nownabe = {gender: :male}
#=> {:gender=>:male}
EasySettings.to_h
#=> {"users"=>{"nownabe"=>{"gender"=>:male}}}
```

Or more simple:

```ruby
EasySettings.users!.nownabe = {gender: :male}
#=> {:gender=>:male}
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
Config.app_name = "AliasSample"
```

Or using class that inherit EasySettings:

```ruby
class Config < EasySettings
  self.namespace = Rails.env
end

Config.endpoint
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/easy_settings/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
