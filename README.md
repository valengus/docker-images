```bash
.
├── docker.pkr.hcl
├── playbooks
│   ├── oraclelinux9.yml
│   └── python39.yml
└── vars
    ├── oraclelinux9.pkrvars.hcl
    └── python39.pkrvars.hcl
```

### Prepare
```bash
packer init docker.pkr.hcl
export PKR_VAR_github_token="..."
```

### Build
```bash
make build-oraclelinux9
```

### Test
```bash
make test-oraclelinux9
```

### Push
```bash
make push-oraclelinux9
```
