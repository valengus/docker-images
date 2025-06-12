prepare:
	@if [ -z "$$PKR_VAR_github_token" ]; then \
		echo "Error: env var PKR_VAR_github_token not defined or empty"; \
		exit 1; \
	fi
	packer init docker.pkr.hcl

build-%:
	packer build -var-file="vars/${*}.pkrvars.hcl" -only='*.docker.build' docker.pkr.hcl

test-%:
	packer build -var-file="vars/${*}.pkrvars.hcl" -only='*.docker.test' docker.pkr.hcl

push-%:
	packer build -var-file="vars/${*}.pkrvars.hcl" -only='docker.push' docker.pkr.hcl
