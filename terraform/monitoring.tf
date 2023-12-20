
resource "helm_release" "netdata" {
  name       = "netdata"
  repository = "https://netdata.github.io/helmchart/"
  chart      = "netdata"
}