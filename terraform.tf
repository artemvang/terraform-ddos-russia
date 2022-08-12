terraform {
  backend "remote" {
    hostname     = "kecyk.scalr.io"
    organization = "env-t98pf65vlknv0m8"

    workspaces {
      name = "ddos-russia"
    }
  }
}
