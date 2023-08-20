#!/usr/bin/env bats

#load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/mocks/stub'

  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_PATH="terraform"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_GROUP="Terraform"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_APPLY="true"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_BLOCK="Confirm apply"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_ASSUME_ROLE="assumed-role"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_QUEUE="test-queue"
}

teardown() {
  echo "$output" >&3
}

@test "Generate pipeline" {

  stub buildkite-agent

  run "$PWD/hooks/command"

  assert_success

  assert_output --partial "init"
  assert_output --partial "plan"
  assert_output --partial "apply"
  

}


