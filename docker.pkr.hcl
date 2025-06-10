packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  packerstarttime = formatdate("YYYYMMDD", timestamp())
}

variable "base_image" {
  type    = string
  default = "docker.io/library/oraclelinux:9"
}

variable "image_name" {
  type    = string
  default = "oraclelinux9"
}

variable "tags" {
  type    = list(string)
  default = ["latest"]
}

variable "changes" {
  type    = list(string)
  default = [
    "ENV LANG=\"C.UTF-8\"",
    "CMD [\"/usr/bin/bash\"]",
  ]
}

variable "github_username" {
  type        = string
  description = "GitHub username"
  default     = "valengus"
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

## BUILD
source "docker" "build" {
  image          = var.base_image
  run_command    = [ "-dit", "--name", "packer-build-${var.image_name}", "{{.Image}}", "/bin/sh" ]
  changes        = var.changes
  commit         = true
  pull           = true
  login          = true
  login_server   = "ghcr.io"
  login_username = var.github_username
  login_password = var.github_token
}

build {

  name    = var.image_name
  sources = [ "source.docker.build" ]

  provisioner "ansible" {
    playbook_file   = "playbooks/${var.image_name}.yml"
    user            = "root"
    extra_arguments = [ "--extra-vars", "ansible_host=packer-build-${var.image_name} ansible_connection=docker", ]
  }

  provisioner "ansible" {
    playbook_file   = "playbooks/common/cleanup.yml"
    user            = "root"
    extra_arguments = [ "--extra-vars", "ansible_host=packer-build-${var.image_name} ansible_connection=docker", ]
  }

  post-processors {

    post-processor "docker-tag" {
      repository = "local/${var.image_name}"
      tags       = concat(var.tags, [local.packerstarttime,])
    }

  }

}

# TEST
source "docker" "test" {
  image       = "local/${var.image_name}"
  run_command = [ "-dit", "--name", "packer-test-${var.image_name}", "{{.Image}}", "/bin/sh" ]
  discard     = true
  pull        = false
}

build {

  name    = var.image_name
  sources = [ "source.docker.test" ]

  provisioner "ansible" {
    playbook_file   = fileexists("tests/${var.image_name}.yml") ? "tests/${var.image_name}.yml" : "tests/common.yml"
    user            = "root"
    extra_arguments = [ "--extra-vars", "ansible_host=packer-test-${var.image_name} ansible_connection=docker", ]
  }

}


## PUSH
source "docker" "push" {
  image       = "local/${var.image_name}"
  commit      = true
  pull        = false
}

build {
  sources = [ "source.docker.push" ]

  post-processors {

    post-processor "docker-tag" {
      repository          = "ghcr.io/${var.github_username}/${var.image_name}"
      keep_input_artifact = true
      tags                = concat(var.tags, [local.packerstarttime,])
    }

    post-processor "docker-push" {
      login          = true
      login_username = var.github_username
      login_password = var.github_token
      login_server   = "ghcr.io"
    }

  }

}
