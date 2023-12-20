resource "kubernetes_pod" "cliente_pod" {
  metadata {
    name = "cliente-pod"
  }

  spec {
    container {
      name  = "cliente-container"
      image = "curlimages/curl:latest"
      command = ["sleep", "infinity"]
    }
  }
}

resource "kubernetes_deployment" "web_app" {
  metadata {
    name = "web-app"

    labels = {
      webappname = "web-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        webappname = "web-app"
      }
    }

    template {
      metadata {
        labels = {
          webappname = "web-app"
        }
      }

      spec {
        container {
          name    = "web-app"
          image   = "nginx"

          command = ["/bin/sh", "-c", "echo 'welcome to my web app!' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
        }

        dns_config {
          option {
            name  = "ndots"
            value = "2"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "lb" {
  metadata {
    name = "lb"

    labels = {
      webappname = "web-app"
    }
  }

  spec {
    selector = {
      webappname = "web-app"
    }

    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = 80
    }

    type = "LoadBalancer"
  }
}