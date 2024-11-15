# Creating EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = var.master_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  }
  

  tags = {
    Name = var.cluster_name
  }
}

# EKS Node Groups
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "Worker-Node-Group"
  node_role_arn   = var.worker_arn
  subnet_ids      = [var.public_subnet_az1_id, var.public_subnet_az2_id]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key = var.key_name
  }

  ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type  = "ON_DEMAND"  # ON_DEMAND, SPOT
  disk_size      = 20
  instance_types = [var.instance_size]

  labels = {
    role = "${var.cluster_name}-Node-group-role",
    name = "${var.cluster_name}-node_group"
  }
  tags = {
    "Name" = "eks-worker-node"  # This tag will be applied to the instances
  }

}

locals {
  eks_addons = {
    "vpc-cni" = {
      version           = var.vpc-cni-version
      resolve_conflicts = "OVERWRITE"
    },
    "kube-proxy" = {
      version           = var.kube-proxy-version
      resolve_conflicts = "OVERWRITE"
    },
    "coredns" = {
      version           = var.coredns-version
      resolve_conflicts = "OVERWRITE"
    },
    "aws-ebs-csi-driver" = {
      version           = var.amazon_ebs_csi_driver_version
      resolve_conflicts = "OVERWRITE"
    }
  }
}

resource "aws_eks_addon" "example" {
  for_each = local.eks_addons

  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_update = each.value.resolve_conflicts

}