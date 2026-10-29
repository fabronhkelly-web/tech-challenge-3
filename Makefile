.PHONY: help init plan apply configure deploy verify destroy fmt lint

TF  := terraform -chdir=terraform
URL  = $(shell $(TF) output -raw website_url 2>/dev/null)

help:        ## Show available commands
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'

init:        ## terraform init
	$(TF) init

plan: init   ## Preview infrastructure changes
	$(TF) plan

apply: init  ## Provision AWS resources with Terraform
	$(TF) apply

configure:   ## Configure the EC2 instance with Ansible
	cd ansible && ansible-playbook site.yml

deploy:      ## Provision + configure + verify in one step
	./scripts/deploy.sh

verify:      ## Check the Hello World page from this machine
	@curl -fsS $(URL) | grep -q "Hello, World!" && echo "OK: $(URL) serves Hello, World!"

destroy:     ## Delete all AWS resources
	./scripts/destroy.sh

fmt:         ## Format Terraform code
	$(TF) fmt -recursive

lint:        ## Validate Terraform and lint Ansible
	$(TF) fmt -check -recursive
	$(TF) init -backend=false -input=false >/dev/null
	$(TF) validate
	cd ansible && ansible-playbook site.yml --syntax-check -i inventory/hosts.ini.example
	cd ansible && ansible-lint site.yml
