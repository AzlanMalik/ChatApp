
locals {
  availability-zones = ["${var.aws-region}a", "${var.aws-region}b"]
}

/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app-name}-vpc"
    Environment = var.environment
  }
}

/* -------------------------------------------------------------------------- */
/*                               SECURITY GROUPS                              */
/* -------------------------------------------------------------------------- */

resource "aws_security_group" "my-security-group" {
 name        = "${var.app-name}-sg"
 description = "${var.app-name} ${var.environment} security group"
 vpc_id      = aws_vpc.my-vpc.id

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
    Name = "${var.app-name}-sg"
 }
}

/* -------------------------------------------------------------------------- */
/*                                 SUBNETS                                    */
/* -------------------------------------------------------------------------- */

/* ----------------------------- PUBLIC SUBNETS ----------------------------- */
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  count                   = length(var.public-subnets-cidr)
  cidr_block              = element(var.public-subnets-cidr, count.index)
  availability_zone       = element(local.availability-zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app-name}-${element(local.availability-zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
  }
}

/* ----------------------------- PRIVATE SUBNETS ----------------------------- */
resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  count                   = length(var.private-subnets-cidr)
  cidr_block              = element(var.private-subnets-cidr, count.index)
  availability_zone       = element(local.availability-zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.app-name}-${element(local.availability-zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}


/* ---------------------------- INTERNET GATEWAY ---------------------------- */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    "Name"        = "${var.app-name}-igw"
    "Environment" = var.environment
  }
}

/* ------------------------ Elastic-IP (eip) for NAT ------------------------ */
resource "aws_eip" "nat-eip" {
  domain        = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

/* ------------------------------- NAT Gateway ------------------------------ */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = element(aws_subnet.public-subnet.*.id, 0)
  tags = {
    Name        = "nat-gateway-${var.app-name}"
    Environment = "${var.environment}"
  }
}


/* -------------------------------------------------------------------------- */
/*                                ROUTE TABLES                                */
/* -------------------------------------------------------------------------- */

/* ----------- Routing tables to route traffic for Private Subnet ----------- */
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name        = "${var.app-name}-private-route-table"
    Environment = "${var.environment}"
  }
}

/* ------------ Routing tables to route traffic for Public Subnet ----------- */
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name        = "${var.app-name}-public-route-table"
    Environment = "${var.environment}"
  }
}

/* ----------------------- Route for Internet Gateway ----------------------- */
resource "aws_route" "public-internet-gateway" {
  route_table_id         = aws_route_table.public-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

/* -------------------------- Route for NAT Gateway ------------------------- */
resource "aws_route" "private_internet_gateway" {
  route_table_id         = aws_route_table.private-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}


/* -------------------------------------------------------------------------- */
/*                    ASSOCIATING ROUTE TABLES WITH SUBNETS                   */
/* -------------------------------------------------------------------------- */

resource "aws_route_table_association" "public-association" {
  count          = length(var.public-subnets-cidr)
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "private-association" {
  count          = length(var.private-subnets-cidr)
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = aws_route_table.private-route.id
}

/* -------------------------------------------------------------------------- */
/*                         APPLICATION LOAD BALANCER                          */
/* -------------------------------------------------------------------------- */
resource "aws_lb" "my-application-load-balancer" {
 name               = "${var.app-name}-${var.environment}-lb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.my-security-group.id]
 subnets            = [for subnet in aws_subnet.public-subnet : subnet.id]
}

resource "aws_lb_target_group" "my-alb-target-group" {
  name        = "${var.app-name}-${var.environment}-alb-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_lb_listener" "my-lb-listener" {
 load_balancer_arn = aws_lb.my-application-load-balancer.arn
 port              = 80
 protocol          = "HTTP"

 default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-alb-target-group.arn
 }
}
