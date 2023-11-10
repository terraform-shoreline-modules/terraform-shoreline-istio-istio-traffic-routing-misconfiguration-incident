resource "shoreline_notebook" "istio_traffic_routing_misconfiguration_incident" {
  name       = "istio_traffic_routing_misconfiguration_incident"
  data       = file("${path.module}/data/istio_traffic_routing_misconfiguration_incident.json")
  depends_on = [shoreline_action.invoke_get_vs_dr,shoreline_action.invoke_get_services_and_endpoints,shoreline_action.invoke_get_istio_traffic_routing_configuration,shoreline_action.invoke_update_istio_virtual_service_route]
}

resource "shoreline_file" "get_vs_dr" {
  name             = "get_vs_dr"
  input_file       = "${path.module}/data/get_vs_dr.sh"
  md5              = filemd5("${path.module}/data/get_vs_dr.sh")
  description      = "Check the Istio VirtualServices and DestinationRules"
  destination_path = "/agent/scripts/get_vs_dr.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "get_services_and_endpoints" {
  name             = "get_services_and_endpoints"
  input_file       = "${path.module}/data/get_services_and_endpoints.sh"
  md5              = filemd5("${path.module}/data/get_services_and_endpoints.sh")
  description      = "Check the Kubernetes Services and Endpoints"
  destination_path = "/agent/scripts/get_services_and_endpoints.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "get_istio_traffic_routing_configuration" {
  name             = "get_istio_traffic_routing_configuration"
  input_file       = "${path.module}/data/get_istio_traffic_routing_configuration.sh"
  md5              = filemd5("${path.module}/data/get_istio_traffic_routing_configuration.sh")
  description      = "Check the Istio traffic routing configuration for any errors or inconsistencies. Verify that the routing rules are correctly defined and applied to the relevant services and workloads."
  destination_path = "/tmp/get_istio_traffic_routing_configuration.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_istio_virtual_service_route" {
  name             = "update_istio_virtual_service_route"
  input_file       = "${path.module}/data/update_istio_virtual_service_route.sh"
  md5              = filemd5("${path.module}/data/update_istio_virtual_service_route.sh")
  description      = "Update the traffic routing rules to correct any misconfigurations. This may involve modifying the routing rules, updating the service definitions, or changing the networking configuration."
  destination_path = "/tmp/update_istio_virtual_service_route.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_vs_dr" {
  name        = "invoke_get_vs_dr"
  description = "Check the Istio VirtualServices and DestinationRules"
  command     = "`chmod +x /agent/scripts/get_vs_dr.sh && /agent/scripts/get_vs_dr.sh`"
  params      = ["NAMESPACE"]
  file_deps   = ["get_vs_dr"]
  enabled     = true
  depends_on  = [shoreline_file.get_vs_dr]
}

resource "shoreline_action" "invoke_get_services_and_endpoints" {
  name        = "invoke_get_services_and_endpoints"
  description = "Check the Kubernetes Services and Endpoints"
  command     = "`chmod +x /agent/scripts/get_services_and_endpoints.sh && /agent/scripts/get_services_and_endpoints.sh`"
  params      = ["NAMESPACE"]
  file_deps   = ["get_services_and_endpoints"]
  enabled     = true
  depends_on  = [shoreline_file.get_services_and_endpoints]
}

resource "shoreline_action" "invoke_get_istio_traffic_routing_configuration" {
  name        = "invoke_get_istio_traffic_routing_configuration"
  description = "Check the Istio traffic routing configuration for any errors or inconsistencies. Verify that the routing rules are correctly defined and applied to the relevant services and workloads."
  command     = "`chmod +x /tmp/get_istio_traffic_routing_configuration.sh && /tmp/get_istio_traffic_routing_configuration.sh`"
  params      = ["NAMESPACE","SERVICE_NAME","WORKLOAD_NAME"]
  file_deps   = ["get_istio_traffic_routing_configuration"]
  enabled     = true
  depends_on  = [shoreline_file.get_istio_traffic_routing_configuration]
}

resource "shoreline_action" "invoke_update_istio_virtual_service_route" {
  name        = "invoke_update_istio_virtual_service_route"
  description = "Update the traffic routing rules to correct any misconfigurations. This may involve modifying the routing rules, updating the service definitions, or changing the networking configuration."
  command     = "`chmod +x /tmp/update_istio_virtual_service_route.sh && /tmp/update_istio_virtual_service_route.sh`"
  params      = ["ORIGINAL_ROUTE","NEW_ROUTE","NAMESPACE","SERVICE_NAME","GATEWAY"]
  file_deps   = ["update_istio_virtual_service_route"]
  enabled     = true
  depends_on  = [shoreline_file.update_istio_virtual_service_route]
}

