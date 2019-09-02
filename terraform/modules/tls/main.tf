data "aws_s3_bucket_object" "tls_secret_key" {
  bucket = var.secrets_storage
  key    = "${var.cluster_name}/tls/${var.cluster_name}.key"
}

data "aws_s3_bucket_object" "tls_secret_crt" {
  bucket = var.secrets_storage
  key    = "${var.cluster_name}/tls/${var.cluster_name}.fullchain.crt"
}