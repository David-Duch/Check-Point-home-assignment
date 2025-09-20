resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name    = "${var.name}-vpc"
    Project = var.project
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name    = "${var.name}-igw"
    Project = var.project
  }
}

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

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name    = "${var.name}-nat-${each.key}"
    Project = var.project
  }
}

resource "aws_nat_gateway" "this" {
  for_each     = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  
  tags = {
    Name    = "${var.name}-nat-${each.key}"
    Project = var.project
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name    = "${var.name}-private-rt-${each.key}"
    Project = var.project
  }
}

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

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
