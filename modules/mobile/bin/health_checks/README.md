# Mobile API Health Checks

Due to the nature of the VA mobile API as a middle point between the mobile app and other upstream services, much of our local development must be done via testing against recorded responses. This is inherently limited and sometimes results in bugs due to incorrect assumptions about upstream services or due to upstream instability. The endpoint tester script is intended to allow us to easily run some very basic checks against deployed environments to ensure that our changes work when upstream requests are being made.

These scripts are also intended to serve as a kind of smoke test to help us better understand when upstream services are down. With some refinement, we should be able to identify which upstream services each test is reliant on and use that information to infer which upstream services might be down.

Additionally, the token fetcher script here can be used on its own to fetch user tokens from staging. It outputs the token in the command line and also copies it to the clipboard.

## Setup

Requires: brew, ruby, and bundler

* `brew install geckodriver`
* in this directory: `bundle install`
* You will need to set up a YAML file with test user credentials. That file should *not* be version controlled, so it is strongly recommended that you do not keep it in this repo. Set an environment variable called `STAGING_TEST_USERS` in your profile that points to this file. The top level keys in that file must match the usernames used in the test files in the `request_data` folder. The file must be formatted like:

```
judy:
  email: 'judy@example.com'
  password: 'redacted'
```

## Usage

To run all tests:
`bundle exec ruby endpoint_tester.rb run_tests`

To run a specific test named "V0 get user":
`bundle exec ruby endpoint_tester.rb run_tests --test_name "V0 get user"`

To run tests against a review instance or environment other than staging (more work may be needed to make this work with the socks proxy):
`bundle exec ruby endpoint_tester.rb run_tests --base_url http://testurl.com`

To fetch a test user's api token:
`bundle exec ruby token_fetcher.rb judy`

## Creating New Tests

New tests are added by creating yaml files in the `request_data` directory. Yaml was chosen to make it easy for non-developers to add new tests. Files are expected to have a top-level `sequence` key containing an array of `case` keys. The idea is to be able to create a full CRUD life-cycle test in a single file. In other words, a sequence could consist of creating a record, listing the record, updating the record, then deleting the record. At this time, only GET requests are supported. We should discuss the ramifications of automating staging changes before adding other request types.

All cases are expected to test the response status, but all other checks are optional. The `attributes` section is intended to be very flexible. We don't necessarily want to check all attributes because many of them are susceptible to change. These scripts are primarily intended as a health check or smoke test. A test can consist of the full expected response, a partial body response, or as little as the expected status.