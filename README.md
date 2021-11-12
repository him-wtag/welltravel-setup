# Welltravel-Setup

This script will do the basic setup for these WellTravel projects for MAC ( meta affiliate agent keycloak )

The script will...

- Clone the projects
- Install node versions using nvm ( 8.17.0 -for meta && 12.18.2 -for other projects )
  - These versions are hardcoded since there is no .nvmrc present in the projects
- Install specific ruby version using rbenv defined in `.ruby-version`
- Run bundle install
- Run yarn install
- Create, load and seed database

You can include other projects by modifying the PROJECT_NAMES array at top.

## Prerequisite

- nvm: for installing node versions
- rbenv: for installing ruby versions

## Steps to Run

- Clone the repo
- `cd welltravel-setup && chmod +x setup.sh`
- `./setup.sh &> output.txt` ( The script output will be saved in a output.txt file. If you want to see the output in terminal, run `./setup.sh` only )
