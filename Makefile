.SILENT:

help:
	grep --extended-regexp '^[a-zA-Z]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-12s\033[0m%s\n", $$1, $$2 }'

init: # terraform init + create ssh keys and passphrase
	./init.sh

validate: # terraform format then validate
	terraform fmt -recursive
	terraform validate

apply: # terraform plan then apply with auto approve
	terraform plan -out=terraform.plan
	terraform apply -auto-approve terraform.plan

clone: # git clone the codecommit repository
	./clone.sh

first-commit: # setup files then git add + commit + push to the codecommit repository
	./first-commit.sh

down: # download + execute hello.out
	./down.sh