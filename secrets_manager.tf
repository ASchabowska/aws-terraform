module "secrets-manager" {

  source = "lgallard/secrets-manager/aws"

  secrets = {
    secret-3 = {
      description             = "My secret 1"
      recovery_window_in_days = 7
      secret_string           = "I am a DevOops engineer"
    }
  }

  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true

  }
}