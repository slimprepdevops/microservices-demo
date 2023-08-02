# Define the required providers
provider "aws" {
  region = var.aws_region
  
}

# Create an AWS EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
  ]
}

# Define an IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the required IAM policy to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Provision the EKS cluster's Kubernetes config locally
data "aws_eks_cluster" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.my_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.my_cluster.token
  load_config_file       = false
}

data "aws_eks_cluster_auth" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}

# Apply Kubernetes manifest configurations
resource "kubernetes_manifest" "apply_deployment" {
  config_path = var.filepath_manifest
}

# Wait for all Pods to be ready before finishing
resource "kubernetes_pod" "wait_conditions" {
  metadata {
    namespace = var.namespace
    name      = "wait-pod"
  }

  spec {
    container {
      image = "busybox"
      name  = "wait-container"

      command = [
        "sh",
        "-c",
        "while true; do sleep 30; done;"
      ]
    }
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "kubectl wait --for=condition=ready pod/wait-pod -n ${var.namespace} --timeout=-1s 2> /dev/null"
  }

  depends_on = [
    kubernetes_manifest.apply_deployment,
  ]
}

