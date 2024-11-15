# Creating VPC
module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
}


# Creating IAM resources
module "iam" {
  source = "./modules/iam"
}


# Creating EKS Cluster
module "eks" {
  source = "./modules/eks"
  master_arn = module.iam.master_arn
  worker_arn = module.iam.worker_arn
  instance_size = var.instance_size
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
  key_name = var.key_name
  vpc-cni-version = var.vpc-cni-version
  kube-proxy-version = var.kube-proxy-version
  coredns-version = var.coredns-version
  amazon_ebs_csi_driver_version = var.amazon_ebs_csi_driver_version
}