# You can override defaults here
region         = "us-east-1"
cluster_name   = "amazon-prime-cluster"
cluster_version = "1.30"

# Node configuration
node_instance_types = ["t3.medium"]
capacity_type       = "ON_DEMAND"
desired_nodes       = 2
min_nodes           = 1
max_nodes           = 3  # Stay within Learner Lab's 9 instance limit

# Network configuration
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]
public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]