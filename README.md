# Simple Terraform Buildkite Plugin

A Buildkite plugin for taking the monotony out of writing typical terraform workflow pipelines.

## Tests
```
docker-compose run --rm tests
```

Instructions to add bats plugins:
```
git submodule add https://github.com/bats-core/bats-assert.git tests/test_helper/bats-assert/
git submodule add https://github.com/bats-core/bats-support.git tests/test_helper/bats-support/
git submodule add https://github.com/jasonkarns/bats-mock tests/test_helper/mocks
```

## Example
Add the following to your `pipeline.yml`:

```yml
steps:
  - label: "Terraform"
    plugins:
    - gantry-ml/simple-terraform#v1.0.0:
        path: "my-terraform-directory"
        apply: true
        block: ":terraform: Confirm Apply"
        group: "Test Group"
        assume-role: "test-role"
        queue: "test-queue"
```

This will yield a pipeline approximately like:

```yml
- group: "Terraform"
  steps:
    - label: ":terraform: Init "
      agents:
        queue: test-queue
      plugins:
      - gantry-ml/aws-assume-role-in-current-account#v0.0.3:
          role: "assumed-role"
          duration: "1800"
      - docker:
          image: "hashicorp/terraform:latest"
          propagate-environment: true
          propagate-aws-auth-tokens: true
          command:
            - -chdir=terraform
            - init
      - artifacts:
          compressed: terraform.tgz
          upload: [ "my-terraform-directory/.terraform", "my-terraform-directory/.terraform.lock.hcl" ]

    - wait

    - label: ":terraform: Validate "
      agents:
        queue: test-queue
      plugins:
      - gantry-ml/aws-assume-role-in-current-account#v0.0.3:
          role: "assumed-role"
          duration: "1800"
      - docker:
          image: "hashicorp/terraform:latest"
          propagate-environment: true
          propagate-aws-auth-tokens: true
          command:
            - -chdir=terraform
            - validate
      - artifacts:
          compressed: terraform.tgz
          download: [ "my-terraform-directory/.terraform", "my-terraform-directory/.terraform.lock.hcl" ]

    - wait

    - label: ":terraform: Plan "
      agents:
        queue: test-queue
      plugins:
      - gantry-ml/aws-assume-role-in-current-account#v0.0.3:
          role: "assumed-role"
          duration: "1800"
      - docker:
          image: "hashicorp/terraform:latest"
          propagate-environment: true
          propagate-aws-auth-tokens: true
          command:
            - -chdir=terraform
            - plan
            - -input=false
            - -out=plan.tfplan
      - artifacts:
          compressed: terraform.tgz
          download: [ "my-terraform-directory/.terraform", "my-terraform-directory/.terraform.lock.hcl" ]
      artifact_paths:
        - "my-terraform-directory/plan.tfplan"

    - wait

    - block: "Confirm Apply "

    - label: ":terraform: Apply "
      agents:
        queue: test-queue
      plugins:
      - gantry-ml/aws-assume-role-in-current-account#v0.0.3:
          role: "assumed-role"
          duration: "1800"
      - docker:
          image: "hashicorp/terraform:latest"
          propagate-environment: true
          propagate-aws-auth-tokens: true
          command:
            - -chdir=terraform
            - apply
            - -auto-approve
            - -input=false
            - plan.tfplan
      - artifacts:
          compressed: terraform.tgz
          download: [ "my-terraform-directory/.terraform", "my-terraform-directory/.terraform.lock.hcl" ]
      - artifacts:
          download: "my-terraform-directory/plan.tfplan"
```      
... which will then be uploaded by the agent via `buildkite-agent pipeline upload` 


## Configuration

### `path` (required, string)
Relative path to the terraform configuration
- Use '.' for the build directory
- This directory is mounted as /workdir in the Terraform container

### `group` (optional, string)
If specified, add all steps to a group using of this name
> Default: null

### `validate` (optional, boolean)
Whether to run a `terraform validate` step
> Default: true

### `init` (optional, boolean)
Whether to run a `terraform init` step
> Default: true

### `plan` (optional, boolean)
Whether to run a `terraform plan` step
> Default: true

### `wait` (optional, boolean)
Whether to add `wait` between each (init, validate, plan, apply) step
> Default: true
 
### `block` (optional, string)
If set, add a `block` before `apply` or `destroy` steps using the specified message.
> Default: null

### `init-args` (optional, string)
Arguments to pass to `terraform init`
> Default: -input=false

### `validate-args` (optional, string)
Arguments to pass to `terraform validate`
> Default: null

### `plan-args` (optional, string)
Arguments to pass to `terraform plan`
> Default: -out=tfplan.out -input=false

### `apply-args` (optional, string)
Arguments to pass to `terraform apply`
> Default: -auto-approve -input=false tfplan.out

### `destroy-args` (string)
Arguments to pass to `terraform destroy`
> Default: -auto-approve -input=false tfplan.out

### `terraform-version` (optional, string)
Version tag of the terraform docker image to use
> Default: latest

### `docker-version` (optional, string)
Version of the Buildkite docker plugin to use. Leave null to use latest.
> Default: null

### `propagate-aws-auth-tokens` (optional, boolean)
Use the [`propagate-aws-auth-tokens` flag for the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin#propagate-aws-auth-tokens-optional-boolean)
> Default: true

### `propagate-environment` (optional, boolean)
Use the [`propagate-environment` flag for the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin#propagate-environment-optional-boolean)
> Default: true

### `queue` (optional, string)
Tag the queue on the generated docker step
> Default: null

### `assume-role` (optional, string)
Assume a role for the docker terraform step using aws-assume-role plugin 
> Default: null

### `suppress-steps` (optional, boolean)
Suppress `steps:` from the pipeline output
> Default: false
> 
### `debug` (optional, boolean)
Instead of uploading the pipeline, it will be printed out only. No steps will be run.
> Default: false

### `tag` (optional, string)
Add a tag to generated artifacts and steps. Particularly useful when used in conjuction with `gantry-ml/foreach` plugin.
> Default: null