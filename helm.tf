
# Explicitly create namespaces
resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
  }
  depends_on = [
    module.eks.cluster_id
  ]
}

resource "kubernetes_namespace" "monitoring" {
  count = local.env == "default" ? 1 : 0
  metadata {
    name = "monitoring"
  }
  depends_on = [
    module.eks.cluster_id
  ]
}

provider "helm" {
  version        = "~> 1.2.3"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

resource "helm_release" "hello-chart" {
  name      = "hello-chart"
  chart     = "${path.module}/hello-chart"
  namespace = kubernetes_namespace.apps.metadata[0].name
  values = [
    templatefile("./hello-chart/values.yaml", { ingress_host = "hello.${local.base_domain}", ingress_paths = "[\"/\"]" })
  ]
  provisioner "local-exec" {
    command = "helm --kubeconfig kubeconfig_${module.eks.cluster_id} test -n ${self.namespace} ${self.name}"
  }
}

resource "helm_release" "metrics-server" {
  count     = local.env == "default" ? 1 : 0
  name      = "metrics-server"
  chart     = "stable/metrics-server"
  version   = "2.8.2"
  namespace = "kube-system"

  values    = [
    "${file("./charts/metrics-server/values.yaml")}",
  ]

  provisioner "local-exec" {
    command = "helm --kubeconfig kubeconfig_${module.eks.cluster_id} test -n ${self.namespace} ${self.name}"
  }

  depends_on = [
    module.eks.cluster_id
  ]
}

resource "helm_release" "prometheus" {
  count   = local.env == "default" ? 1 : 0
  name    = "prometheus"
  chart   = "stable/prometheus-operator"
  version = "8.13.11"
  namespace = "monitoring"

  # set {
  #   name  = "grafana.adminPassword"
  #   value = var.GRAFANA_PWD
  # }
  # set {
  #   name  = "grafana.ingress.hosts"
  #   value = "[grafana.${local.base_domain}]"
  # }
  values    = [
    templatefile("./charts/prometheus/values.yaml", { grafana_pwd = var.GRAFANA_PWD, base_domain = local.base_domain })
  ]
  provisioner "local-exec" {
    command = "helm --kubeconfig kubeconfig_${module.eks.cluster_id} test -n ${self.namespace} ${self.name}"
  }

  depends_on = [
    module.eks.cluster_id
  ]
}

resource "helm_release" "cluster-autoscaler" {
  count     = local.env == "default" ? 1 : 0
  name = "cluster-autoscaler"
  chart = "stable/cluster-autoscaler"
  version = "7.1.0"
  namespace = "kube-system"
  values    = [
    "${file("./charts/cluster-autoscaler/values.yaml")}",
  ]

  provisioner "local-exec" {
    command = "helm --kubeconfig kubeconfig_${module.eks.cluster_id} test -n ${self.namespace} ${self.name}"
  }

  depends_on = [
    module.eks.cluster_id
  ]
}


