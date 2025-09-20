resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name    = "${var.name}-vpc"
    Project = var.project
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name    = "${var.name}-igw"
    Project = var.project
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name    = "${var.name}-public-rt"
    Project = var.project
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => { cidr = cidr, az = var.availability_zones[idx] }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.name}-public-${each.key}"
    Project = var.project
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => { cidr = cidr, az = var.availability_zones[idx] }
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name    = "${var.name}-private-${each.key}"
    Project = var.project
  }
}
