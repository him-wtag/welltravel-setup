## `Welltravel Setup`

This script will do the basic setup for these WellTravel projects ( `meta affiliate agent keycloak` )

The script will...

- Clone the projects if not found in the project directory
- Install node versions using nvm ( v 12.18.2 )
- Install specific ruby version using rbenv defined in `.ruby-version`
- Run `bundle install`
- Run `yarn install`
- Create, load and seed database

You can include other projects by modifying the `$PROJECT_NAMES` variable at the top of script.

### `Prerequisite`

- Create a Personal Access Token on GitHub which has the scopes `repo, write:packages, read:packages and delete:packages.`
- Get the node bit credential for installing private npm packages
- Install [nvm](https://github.com/nvm-sh/nvm): for installing node versions
- Install [rbenv](https://github.com/rbenv/rbenv): for installing ruby versions

### `Steps to Run`

  1. Clone the repo
  2. Update the $PROJECT_DIR variable in top with your project root directory
  3. Make setup.sh executable - `chmod +x setup.sh`
  4. run `./setup.sh`
