#!/usr/bin/env groovy

REPOSITORY = 'finder-frontend'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(
        numToKeepStr: '50')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ThrottleJobProperty',
      categories: [],
      limitOneJobWithMatchingParams: true,
      maxConcurrentPerNode: 1,
      maxConcurrentTotal: 0,
      paramsToUseForLimit: 'finder-frontend',
      throttleEnabled: true,
      throttleOption: 'category'],
    [$class: 'ParametersDefinitionProperty',
      parameterDefinitions: [
        [$class: 'BooleanParameterDefinition',
          name: 'IS_SCHEMA_TEST',
          defaultValue: false,
          description: 'Identifies whether this build is being triggered to test a change to the content schemas'],
        [$class: 'StringParameterDefinition',
          name: 'SCHEMA_BRANCH',
          defaultValue: 'deployed-to-production',
          description: 'The branch of govuk-content-schemas to test against']]
    ]
  ])

  try {
    if (env.BRANCH_NAME == 'deployed-to-production') {
      if (env.IS_SCHEMA_TEST == "true") {
        echo "Branch is 'deployed-to-production' and this is a schema test " +
          "build. Proceeding with build."
      } else {
        echo "Branch is 'deployed-to-production', but this is not marked as " +
          "a schema test build. 'deployed-to-production' should only be " +
          "built as part of a schema test, so this build will stop here."
        currentBuild.result = "SUCCESS"
        return
      }
    }

    stage("Configure environment") {
      govuk.setEnvar("RAILS_ENV", "test")
      govuk.setEnvar("GOVUK_APP_DOMAIN", "test.gov.uk")
      govuk.setEnvar("GOVUK_ASSET_ROOT", "http://static.test.gov.uk")
    }

    stage("Checkout") {
      checkout scm
    }

    stage("Clean up workspace") {
      govuk.cleanupGit()
    }

    stage("git merge") {
      govuk.mergeMasterBranch()
    }

    stage("Set up content schema dependency") {
      govuk.contentSchemaDependency(env.SCHEMA_BRANCH)
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")
    }

    stage("bundle install") {
      govuk.bundleApp()
    }

    stage("Precompile assets") {
      govuk.precompileAssets()
    }

    stage("rubylinter") {
      govuk.rubyLinter()
    }

    stage("Run tests") {
      govuk.runRakeTask("default")
    }

    if (env.BRANCH_NAME == 'master') {
      stage("Push release tag") {
        govuk.pushTag(REPOSITORY, env.BRANCH_NAME, 'release_' + env.BUILD_NUMBER)
      }

      govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, 'release', 'deploy')
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
