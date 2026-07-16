module "site" {
  source      = "./modules/static-site"
  bucket_name = var.bucket_name
}
