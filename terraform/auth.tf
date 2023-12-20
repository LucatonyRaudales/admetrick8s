
resource "kubernetes_secret" "auth" {
  type = "Opaque"
  metadata {
    name = "basic-auth"
  }
  data = {
    "auth" : "admin"
  }
}