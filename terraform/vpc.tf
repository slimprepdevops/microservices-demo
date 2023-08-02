# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = "main"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "staging"
  }
}

enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "spot"
      }

      taints = [{
        key    = "market"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }

  tags = {
    Environment = "staging"
  }