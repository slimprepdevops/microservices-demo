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

variable "aws_region" {
  description = "AWS region for the resources."
  type        = string
default = us-east-1
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
default     = "online-boutique"
}

variable "subnet_ids" {
  description = "List of subnet IDs in which to place the EKS cluster."
  type        = list(string)
default = module.vpc.private_subnets
}

variable "filepath_manifest" {
  description = "Path to the Kubernetes manifest file to apply."
  type        = string
default     = "../kustomize/"
}

variable "namespace" {
  description = "Kubernetes namespace to apply the manifest to."
  type        = string
default     = "default"
}
