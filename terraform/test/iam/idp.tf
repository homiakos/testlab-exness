resource "aws_iam_saml_provider" "gsuite" {
  name                   = "GSuite1"
  saml_metadata_document = file("${path.cwd}/GoogleIDPMetadata.xml")
}