#!/bin/zsh

declare -a PROJECT_NAMES=(meta keycloak affiliates agent)
PROJECT_DIR=$HOME/Projects/wtag/WellTravel/sldkfjl

# put the envs in in ~/.zshrc ( or ~/.bashrc for linux ) for future use
# Token scope: repo, write:packages, read:packages and delete:packages.

if ! [[ -d $PROJECT_DIR ]]; then
  echo -e "\e[31m Project Directory is invalid. \n Please specify a valid path for \$PROJECT_DIR in top of the script \e[0m"
  exit 1;
fi

# TOKEN=<github personal access token>
# GIT_USERNAME=<your github username>
if ! [[ $GITHUB_PACKAGES_TOKEN && $NPM_TOKEN ]]; then
  if [[ $TOKEN && $GIT_USERNAME ]]; then
    export NPM_TOKEN=$TOKEN
    export GITHUB_PACKAGES_TOKEN=$TOKEN
    export GH_PACKAGES_ACCESS_TOKEN=$TOKEN
    export BUNDLE_RUBYGEMS__PKG__GITHUB__COM="$GIT_USERNAME:$TOKEN"
    export BUNDLE_GITHUB__COM=$TOKEN
  else
    echo -e "\e[31mPlease modify the script's TOKEN and GITHUB_USERNAME value \e[0m"
    echo -e "\e[31mOr, define these environment variables in your ~/.zshrc or ~/.bashrc \n\e[0m"
    echo "NPM_TOKEN=<node bit access token https://node.bit.dev>"
    echo "GITHUB_PACKAGES_TOKEN=<github_access_token>"
    echo "GH_PACKAGES_ACCESS_TOKEN=<github_access_token>"
    echo "BUNDLE_RUBYGEMS__PKG__GITHUB__COM=<git_username:github_access_token>"
    echo "BUNDLE_GITHUB__COM=<github_access_token>"
    exit 1
  fi
fi

[[ -f $HOME/.zshrc ]] && source ~/.zshrc;

# Helper texts
welcome_message="Running script..."
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

# Helper methods to print messages in colored text
function error { echo -e "\n\e[31m$@\e[0m" } # RED
function info { echo -e "\n\e[32m$@\e[0m" }  # GREEN
function warn { echo -e "\n\e[33m$@\e[0m" }  # ORANGE
function debug { echo -e "\n\e[34m$@\e[0m" } # BLUE

warn $welcome_message

function bundler_config() {
  info "Setting Configs for some gems.."
  # Install these gems with the flag, to avoid compilation error
  for gem in nio4r pg debase; do
    bundle config --global build.$gem --with-cflags="-Wno-error=implicit-function-declaration"
  done
}

function setup_node() {
  info "Installing Node versions"

  if [[ -s $HOME/.nvm/nvm.sh ]] ;then
    error "NVM not installed. Skipping installing node"
    error "Visit <https://github.com/nvm-sh/nvm#installing-and-updating> to install NVM"
    return
  fi

  source ~/.nvm/nvm.sh  # make nvm command available, install nvm first if you didn't already
  nvm install 12.18.2
}

function clone_project() {
  warn "$PROJECT: Project not found the directory"
  debug "$PROJECT: Clonnig Project from remote..."

  git clone git@github.com:wtag/$1.git
}

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

function main() {
  DIR=$PROJECT_DIR

  warn "\nStarting Setup..."
  debug "Current Directory: $DIR"

  bundler_config
  setup_node

  for project_name in $PROJECT_NAMES; do
    export PROJECT=$project_name
    warn "\n### Project Name: $PROJECT ###"

    if ! [[ -d "$DIR/$project_name" ]]; then
      clone_project $project_name
    fi

    dir=$DIR/$project_name

    cd $dir

    setup_ruby
    setup_bundle
    setup_yarn
    setup_database

    cd $DIR

  done
}
# 2>&1 dumps the stderr and stdout streams
main 2>&1 | tee log.json

echo "Finished! Check logs.json file to check if everything went smoothly."
