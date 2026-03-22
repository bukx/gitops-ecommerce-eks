###############################################################################
# VPC Module — Multi-AZ with public/private subnets and NAT gateways
###############################################################################

variable "name"               { type = string }
variable "cidr"               { type = string; default = "10.0.0.0/16" }
variable "availability_zones" { type = list(string) }
variable "private_subnets"    { type = list(string) }
variable "public_subnets"     { type = list(string) }
variable "enable_nat_gateway" { type = bool; default = true }
variable "single_nat_gateway" { type = bool; default = false }
variable "tags"               { type = map(string); default = {} }

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, { Name = var.name })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name                                = "${var.name}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = merge(var.tags, {
    Name                                     = "${var.name}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/${var.name}"      = "shared"
  })
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${var.name}-nat-${count.index}" })
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
  }
  tags = merge(var.tags, { Name = "${var.name}-private-rt-${count.index}" })
}

resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

output "vpc_id"               { value = aws_vpc.main.id }
output "public_subnet_ids"    { value = aws_subnet.public[*].id }
output "private_subnet_ids"   { value = aws_subnet.private[*].id }
output "private_subnet_cidrs" { value = aws_subnet.private[*].cidr_block }
output "nat_gateway_ips"      { value = aws_eip.nat[*].public_ip }
