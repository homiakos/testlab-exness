//locals {
//  r53_records = flatten([
//    for ns in var.namespaces : [
//      for alb, desc in lookup(ns, "r53", null) == null ? {} : ns.r53 : [
//        for record in desc.hostnames : {
//          elb       = elb
//          private   = desc.private
//          s_private = desc.private == true ? "private" : "public"
//          hostname  = record
//          domain    = join(".", [element(split(".", record), length(split(".", record)) - 2), element(split(".", record), length(split(".", record)) - 1)])
//        }
//      ]
//    ]
//  ])
//  domain_list = distinct(flatten([
//    for ns in var.namespaces : [
//      for alb, desc in lookup(ns, "r53", null) == null ? {} : ns.r53 : [
//        for record in desc.hostnames : {
//          name      = join(".", [element(split(".", record), length(split(".", record)) - 2), element(split(".", record), length(split(".", record)) - 1)])
//          private   = desc.private
//          s_private = desc.private == true ? "private" : "public"
//        }
//      ]
//    ]
//  ]))
//}
//
//provider "aws" {
//  alias = "dns"
//}
//
//data "aws_route53_zone" "this" {
//  for_each = { for domain in local.domain_list : "${domain.name}-${domain.s_private}" => domain }
//  provider = aws.dns
//
//  private_zone = each.value.private
//  name         = each.value.name
//}
//
//resource "aws_route53_record" "this" {
//  for_each = { for record in local.r53_records : "${record.hostname}-${record.s_private}" => record }
//  provider = aws.dns
//
//  name    = each.value.hostname
//  type    = "A"
//  zone_id = data.aws_route53_zone.this["${each.value.domain}-${each.value.s_private}"].zone_id
//  alias {
//    evaluate_target_health = false
//    name                   = var.eks_albs[each.value.elb].dns_name
//    zone_id                = var.eks_albs[each.value.elb].zone_id
//  }
//}
