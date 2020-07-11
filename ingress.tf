resource "aws_acm_certificate" "cert" {
  domain_name               = "*.${local.base_domain}"
# See https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html#alternative-domains-dns-validation-with-route-53
#   subject_alternative_names = [
#     "*.${local.cluster_name}.${local.base_domain}",
#     "${local.cluster_name}.${local.base_domain}"
#   ]
  validation_method         = "DNS"
}
resource "aws_route53_zone" "zone" {
  name = local.base_domain
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.zone.zone_id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
# }

resource "helm_release" "ingress" {
  name = "ingress"
  chart = "stable/nginx-ingress"
  # version = "1.40.3"
  namespace = "kube-system"
  cleanup_on_fail = "true"
  atomic = "true"

  values    = [
    templatefile("./charts/nginx-ingress/values.yaml", { certificate_arn = aws_acm_certificate.cert.arn})
  ]
  
  provisioner "local-exec" {
    command = "helm --kubeconfig kubeconfig_${module.eks.cluster_id} test -n ${self.namespace} ${self.name}"
  }

  depends_on = [
    module.eks.cluster_id
  ]
}