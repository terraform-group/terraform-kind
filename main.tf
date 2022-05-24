provider "kind" {}

resource "kind_cluster" "default" {
  name           = "test-cluster"
  node_image     = "kindest/node:v1.24.0"
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      kubeadm_config_patches = [
        <<-EOT
          kind: InitConfiguration
          imageRepository: registry.aliyuncs.com/google_containers
          networking:
            serviceSubnet: 10.0.0.0/16
          nodeRegistration:
            kubeletExtraArgs:
              node-labels: "ingress-ready=true"
          ---
          kind: KubeletConfiguration
          cgroupDriver: systemd
          cgroupRoot: /kubelet
          failSwapOn: false
        EOT
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}