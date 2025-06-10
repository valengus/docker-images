### Prepare
```bash
packer init docker.pkr.hcl
export PKR_VAR_github_token="..."
```

### Build
```bash
packer build -var-file="vars/oraclelinux9.pkrvars.hcl" -only='*.docker.build' docker.pkr.hcl
```

### Test
```bash
packer build -var-file="vars/oraclelinux9.pkrvars.hcl" -only='*.docker.test' docker.pkr.hcl
```

### Push
```bash
packer build -var-file="vars/oraclelinux9.pkrvars.hcl" -only='docker.push' docker.pkr.hcl
```