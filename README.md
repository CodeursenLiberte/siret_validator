![Gem Version](https://badge.fury.io/rb/siret_validator.svg) ![build](https://github.com/CodeursenLiberte/siret_validator/actions/workflows/main.yml/badge.svg)

# siret_validator

This gem provides a Rails validator for french [SIRET numbers](https://entreprendre.service-public.fr/vosdroits/F32135?lang=en).

## Features

* Validate the SIRET format (14 digits),
* Validate the checksum of regular SIRETs (with luhn sum),
* Validate the checksum of La Poste SIRETs (with the alternative checksum formula),
* Clear localized error messages,
* Ad-hoc error messages support.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add siret_validator
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install siret_validator
```

Alternatively, you can vendor the gem by just copy-pasting the `lib/siret_validator.rb` file into your `app/validators` directory.

## Usage

### With ActiveRecord

```ruby
class TaxesFilling < ApplicationRecord
  validates :company_siret, siret: true
end
```

### With ActiveModel

```ruby
class TaxesFilling
  include ActiveModel::Validations

  attr_accessor :company_siret
  validates :company_siret, siret: true
end
```

## I18n

By default, the siret validator may emit two different error messages:

* `:wrong_siret_format` – when the value is not an 14-digits string.

    _The message is localized using a custom `:wrong_siret_format` i18n key. French and English locales are bundled with the gem._
* `:invalid` – when the SIRET checksum is invalid.

    _The message is localized using the standard Rails `:invalid` i18n key._

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `siret_validator.gemspec`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CodeursenLiberte/siret_validator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/CodeursenLiberte/siret_validator/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SiretFormatValidator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/siret_validator/blob/main/CODE_OF_CONDUCT.md).
