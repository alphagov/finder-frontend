#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-finder-frontend")
  govuk.buildProject(
    beforeTest: {
      stage("Lint Javascript") {
        sh("yarn")
        sh("yarn run lint")
      }
      stage("Test Javascript") {
        sh("yarn test")
      }
    },
    sassLint: false,
    publishingE2ETests: true,
    brakeman: true,
    rubyLintDiff: false
  )
}
