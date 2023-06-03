module "secrets-manager" {

  source = "lgallard/secrets-manager/aws"

  secrets = {
    secret-3 = {
      description             = "My secret 1"
      recovery_window_in_days = 7
      secret_string           = "This is an example"
    }
  }

  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true

  }
}