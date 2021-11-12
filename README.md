## `Welltravel Setup`

This script will do the basic setup for these WellTravel projects ( `meta affiliate agent keycloak` )

The script will...

- Clone the projects
- Install node versions using nvm ( 8.17.0 -for meta && 12.18.2 -for other projects )
  - These versions are hardcoded since there is no .nvmrc present in the projects
- Install specific ruby version using rbenv defined in `.ruby-version`
- Run `bundle install`
- Run `yarn install`
- Create, load and seed database

You can include other projects by modifying the `PROJECT_NAMES` array at top.

### `Prerequisite`

- Create a Personal Access Token on GitHub which has the scopes `repo, write:packages, read:packages and delete:packages.`
- Login in Bit from terminal using your credentials
  - Create an account in https://node.bit.dev
  - run from terminal `yarn global add bit-bin`
  - run from terminal `npm login --registry=https://node.bit.dev --scope=@bit`
- Install [nvm](https://github.com/nvm-sh/nvm): for installing node versions
- Install [rbenv](https://github.com/rbenv/rbenv): for installing ruby versions

### `Steps to Run`

  1. Clone the repo
  2. Edit setup.sh and modify the `TOKEN` & `GIT_USERNAME` variable at top
  3. Make setup.sh executable - `chmod +x setup.sh`
  4. `./setup.sh &> output.txt` ( The script output will be saved in a output.txt file. If you want to see the output in terminal, run `./setup.sh` only )
