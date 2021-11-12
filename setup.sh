#!/bin/zsh

declare -a PROJECT_NAMES=(meta keycloak affiliates agent)

function error { echo -e "\n\e[31m$@\e[0m" } # RED
function info { echo -e "\n\e[32m$@\e[0m" }  # GREEN
function warn { echo -e "\n\e[33m$@\e[0m" }  # ORANGE
function debug { echo -e "\n\e[34m$@\e[0m" } # BLUE

welcome_message="This script will clone these projects: $PROJECT_NAMES and do the basic setup.\nInitating script..."
bundler_failed_message='Failed to install gem bundler'
bundle_failed_message='Failed to run bundle install'
bundle_skip_message='No Gemfile.lock found! Skipping bundle install...'
yarn_skip_message='No yarn.lock found! Skipping yarn install...'
yarn_failed_message='Failed to install node packages'
directory_change_message="Changed Directory: $PWD"
database_skip_message="Skipping database setup... database.yml not found!"
creating_database_message="Creating database..."
loading_schema_message="Loading schema..."
seeding_message="Seeding database..."

info $welcome_message

# put these lines in your ~/.zshrc ( or ~/.bashrc for linux ) for future use
TOKEN=<github personal access token>
GIT_USERNAME=<your github username>

export NPM_TOKEN=$TOKEN
export GITHUB_PACKAGES_TOKEN=$TOKEN
export GH_PACKAGES_ACCESS_TOKEN=$TOKEN
export BUNDLE_RUBYGEMS__PKG__GITHUB__COM="$GIT_USERNAME:$TOKEN"
export BUNDLE_GITHUB__COM=$TOKEN

source ~/.zshrc


debug 'Clonnig Projects in ...'
mkdir welltravel && cd welltravel
for project in $PROJECT_NAMES; do git clone git@github.com:wtag/$project.git; done

# Install these gems with the flag, to avoid compilation error
for gem in nio4r pg debase; do
  bundle config --global build.$gem --with-cflags="-Wno-error=implicit-function-declaration"
done

# Install ruby version using rbenv
function setup_ruby() {
  # install Ruby if .ruby-version is there
  ! [[ -f ".ruby-version" ]] && return 0
  ruby_version="$(cat .ruby-version)"
  
  info "$PROJECT: Installing Ruby v$ruby_version"
  
  rbenv install $ruby_version --skip-existing
}

# Install gems using bundler
function setup_bundle() {
  # check if backend folder is present and cd to it
  [[ -d $dir/backend ]] && cd $dir/backend && debug $directory_change_message
  ! [[ -f "Gemfile.lock" ]] && debug $bundle_skip_message && return 0

  info "$PROJECT: Installing gems..."

  bundler_version=$(tail -1 Gemfile.lock)
  gem install bundler -v $bundler_version || error $bundler_failed_message
  bundle install || error $bundle_failed_message
}

# Install node packages using yarn

function setup_yarn() {
  [[ -d $dir/frontend ]] && cd $dir/frontend && debug $directory_change_message
  ! [[ -f "yarn.lock" ]] && debug $yarn_skip_message && return 0
  
  info  "$PROJECT: Installing node packages..."

  [[ $PROJECT == 'meta' ]] && nvm use 8.17.0 || nvm use 12.18.2
  yarn install || error $yarn_failed_message
}

function setup_database() {
  info  "$PROJECT: Setting up database..."

  if [[ -d $dir/backend ]]; then dir=$dir/backend; fi 

  cd $dir

  [[ -f .env.example ]] && ! [[ -f .env ]] && cp .env.example .env

  if [[ -d $dir/config ]]; then 
    cd $dir/config

    [[ -f database.example.yml ]] && ! [[ -f database.yml ]] && cp database.example.yml database.yml

    cd $dir
  fi 

  ! [[ -f $dir/config/database.yml ]] && debug $database_skip_message && return 0

  warn $PWD 

  debug $creating_database_message && rake db:create
  
  debug $loading_schema_message
  if [[ -f $dir/db/schema.rb ]]; then 
    rake db:schema:load
  elif [[ -f $dir/db/structure.sql ]]; then
    rake db:structure:load
  fi

  [[ -f $dir/db/seeds.rb ]] && debug $seeding_message && rake db:seed
}

info "Installing Node versions"

source ~/.nvm/nvm.sh  # make nvm command available, install nvm first if you didn't already
# nvm install 8.17.0 
# nvm install 12.18.2

function main() {
  DIR=$PWD

  warn "\nStarting Setup..."
  debug "Current Directory: $DIR"

  for dir in $DIR/*; do

    if ! [[ -d "$dir" ]]; then continue; fi

    export PROJECT=${dir##*/}

    warn "\n### Project Name: $PROJECT ###"
    cd $dir
    
    # ! [[ $PROJECT == 'meta' ]] && continue 

    setup_ruby
    setup_bundle
    setup_yarn
    setup_database

    cd $DIR

  done
}

main