#!/usr/bin/env bats

#load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/mocks/stub'

  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_PATH="terraform"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_TERRAFORM_MODULE="repo/staging-infra"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_GROUP="Terraform"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_APPLY="true"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_BLOCK="Confirm apply"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_ASSUME_ROLE="assumed-role"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_QUEUE="test-queue"
}

teardown() {
  echo "$output" >&3
}

# @test "Generate pipeline" {

#   stub buildkite-agent

#   actual_output=$( "$PWD/hooks/command" )
#   #echo "start output"
#   #echo "${actual_output}"
#   #echo "end output"

#   expected_output=$(cat tests/files/test1_expected.yaml)

#   assert_equal "${actual_output}" "${expected_output}"
  
# }


@test "Docker blocks" {
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_ENVIRONMENT_0="TF_VAR_repo_version"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_ENVIRONMENT_1="TF_VAR_some_api_key"

  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_DOCKER_IMAGE="hashicorp/terraform"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_TERRAFORM_VERSION="1.3.9"
  stub buildkite-agent

  actual_output=$( "$PWD/hooks/command" )
  #echo "start output"
  #echo "${actual_output}"
  #echo "end output"

  expected_output=$(cat tests/files/test_docker_expected.yaml)

  assert_equal "${actual_output}" "${expected_output}"
  #assert_equal "1" "0"
  
}


