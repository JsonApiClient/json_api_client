source "https://rubygems.org"
source "https://3VRyspynxvkUrsF1waCF@gem.fury.io/me/" do
  gem "yeti_support", ">= 1.9.1"
end

gemspec

gem 'rake'

as_version = ENV["AS_VERSION"] || "default"

as_version = case as_version
when "default"
  ">= 3.2.0"
else
  "~> #{as_version}"
end

gem "activesupport", as_version
gem 'addressable', '~> 2.2'

# 3.2 now requires the minitest gem
if as_version =~ /3\.2\./
  gem "minitest", '~> 5'
end

gem "codeclimate-test-reporter", group: :test, require: nil

group :development, :test do
  gem 'byebug', platforms: [:mri_20, :mri_21, :mri_22]
end
