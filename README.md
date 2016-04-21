# Crier
[![License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![Build Status](https://travis-ci.org/PRX/crier.prx.org.svg)](https://travis-ci.org/PRX/crier.prx.org)
[![Code Climate](https://codeclimate.com/github/PRX/crier.prx.org/badges/gpa.svg)](https://codeclimate.com/github/PRX/crier.prx.org)
[![Coverage Status](https://coveralls.io/repos/PRX/crier.prx.org/badge.svg)](https://coveralls.io/r/PRX/crier.prx.org)
[![Dependency Status](https://gemnasium.com/PRX/crier.prx.org.svg)](https://gemnasium.com/PRX/crier.prx.org)

## Description
Monitor and announce changes to podcast feeds.
It follows the [standards for PRX services](https://github.com/PRX/meta.prx.org/wiki/Project-Standards#services).

It reads RSS feeds, standard and MediaRSS.
When a change of any kind to an rss item is detected, it uses the `announce` gem to send messages for those changes.

## Integrations & Dependencies
- postgres - main database
- AWS SNS & SQS - used by `announce` to submit messages for item create/update/delete

## Installation
These instructions are written assuming Mac OS X install.

### Basics
```
# Homebrew - http://brew.sh/
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# Git - http://git-scm.com/
brew install git
```

### Docker Development
You can now build and run the crier application using docker.
We're using Docker for deployment, so this is also a good way to make sure development and production environments match as much as possible.

#### Prerequisites
[Install Dinghy and related projects](https://github.com/codekitchen/dinghy)
Notes:
* Using 'VirtualBox' is recommended.
* Also be sure to install `docker-compose` along with the toolbox

#### Install Crier
```
# Get the code
git clone git@github.com:PRX/crier.prx.org.git
cd crier.prx.org

# Make .env, start with the example and edit to include AWS & other credentials
cp env-example .env
vim .env

# Build the `web` container, it will also be used for `worker`
docker-compose build

# Start the postgres `db`
docker-compose start db

# ... and run migrations against it
docker-compose run app migrate

# Create SQS (and SNS) configuration
docker-compose run app sqs

# Test
docker-compose run app test

# Guard
docker-compose run app guard

# Run the web, worker, and db
docker-compose up
```

### Local Install
If docker is not your style, you can also run as a regular local Rails application.

#### Ruby and Gems
```
# Pow to serve the app - http://pow.cx/
curl get.pow.cx | sh

brew update

# rbenv and ruby-build - https://github.com/sstephenson/rbenv
brew install rbenv ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# ruby (.ruby-version default)
rbenv install

# bundler and powder gem - http://bundler.io/
gem install bundler powder
```

#### Rails Project
Consider forking the repo if you plan to make changes, otherwise you can clone it:
```
# ssh repo syntax (or https `git clone https://github.com/PRX/crier.prx.org.git crier.prx.org`)
git clone git@github.com:PRX/crier.prx.org.git crier.prx.org
cd crier.prx.org

# bundle to install gems dependencies
bundle install

# copy the env-example, change values if necessary
cp env-example .env

# create databases
bundle exec rake db:create
bundle exec rake db:create RAILS_ENV=test
bundle exec rake db:migrate

# setup sqs and sns for `announce` gem messages
bundle exec sqs:create announce:configure_broker

# run tests
bundle exec rake

# pow set-up
powder link

# see the development status page
open http://crier.prx.dev
```

## License
[AGPL License](https://www.gnu.org/licenses/agpl-3.0.html)

## Contributing
Completing a Contributor License Agreement (CLA) is required for PRs to be accepted.
