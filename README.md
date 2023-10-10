# Sorry Cypress docker compose provisioning script

This repository is intended as a setup script to configure a remote server as a [sorry-cypress](https://docs.sorry-cypress.dev/) stack. It:

1. Installs `docker`
2. Starts a `docker-compose` stack with a [full sorry-cypress stack](https://docs.sorry-cypress.dev/configuration/persistent)
3. Starts a reverse proxy for the cypress director and dashboard

Authentication is done using basic auth, which is set up based on environment variables in the `.env` file.

## Requirements

1. An Ubuntu 22.04 server with a public IP address (recommended minimum of 1G RAM)
2. 3 subdomains of a main domain name pointing to the server

## Usage

1. Clone this repository
2. Populate the `.env` file with the required variables, see `.env.example`
3. Run `bash scripts/provision.sh`
4. Follow the instructions in the script

## Setting up sorry-cypress

1. Follow the [sorry-cypress setup instructions](https://docs.sorry-cypress.dev/guide/get-started)
    - `npm i cypress-cloud`
    - Edit `cypress` CLI for `cypress-coud` [see docs](https://docs.sorry-cypress.dev/guide/get-started#running-cypress-tests-in-parallel)
    - Add `cloudPlugin` to `cypress.config.js`
2. Set `cloudServiceUrl` in your `currents.config.js` to `https://your_user:your_password@sorry-cypress-director.your_domain.com`
3. See `.github-actions.example.yml` for an example for how to set up a parallel resting CI on Github

### Example usage in Github actions

You can use the director in Github Actions by setting `currents.config.js` to:

```js
module.exports = {
    projectId: "APP NAME", // the projectId, can be any values for sorry-cypress users
    recordKey: "xxx", // the record key, can be any value for sorry-cypress users
    cloudServiceUrl: "%%cypress_cloud_service_url%%",   // Sorry Cypress users - set the director service URL
}
```

And in Github Actions add the URL with authentication using:

```bash
sed -i "s;%%cypress_cloud_service_url%%;${{ secrets.CYPRESS_CLOUD_SERVICE_URL }};g" currents.config.js
```

You can then run parallel testing using:

```yml
strategy:
      fail-fast: false
      matrix:
        # run 3 copies of the current job in  parallel
        containers: [ 1, 2, 3 ]
```

You can save the artifacts of the containers for debugging by using:

```yml
# If CI failed, upload the videos for debugging
- name: Upload cypress video files
if: always() # you can optionally set this to failure()
uses: actions/upload-artifact@v3
with:
    name: cypress-videos ${{ matrix.containers }}
    path: |
    cypress/videos
    cypress/screenshots
```

## Notes

**Buildjet is highly recommended**

[Buildjet](https://buildjet.com/for-github-actions) (no affiliation) supplies Github Action runners that have more resources. It makes running tests in parallel a lot faster. They have a free tier, and the paid tiers are priced reasonably based on usage. If Cypress charged reasonable fees like Buildjet, this repository would not exist. I hope you're listening Cypress.

**Only the director is essential**

The dashboard and API containers are nice for having a dashboard to view from, but there is no need for them if you just want to run tests in parallel and use local recordings for debugging.

**Containers are isolated from the internet**

The docker stack only exposes the `sorry-cypress` containers through the reverse proxy. You can test this by running:

```bash
source .env

function test_port() {
    nc -vz $SSH_IP $1
}

# Testing the cypress ports
test_port 1234
test_port 4000
test_port 8080

# Testing the reverse proxy ports
test_port 80
test_port 443
```