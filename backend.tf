# terraform {
#   backend "s3" {
#     bucket         = "reyzi-dev-state-bucket-2k26"
#     key            = "reyzi/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "reyzi-state-locking"
#     encrypt        = true
#   }
# }