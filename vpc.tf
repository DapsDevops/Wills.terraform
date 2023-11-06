# create Prod vpc
resource "aws_vpc" "Prod_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Prod_vpc"
  }
}
#create Prodpublic subnets
resource "aws_subnet" "Prod_pub_sub1" {
  vpc_id     = aws_vpc.Prod_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod_pub_sub1"
  }
}
resource "aws_subnet" "Prod_pub_sub2" {
  vpc_id     = aws_vpc.Prod_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod_pub_sub2"
  }
}
#Create Prod private subnets
resource "aws_subnet" "Prod_priv_sub1" {
  vpc_id     = aws_vpc.Prod_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod_priv_sub1"
  }
}
resource "aws_subnet" "Prod_priv_sub2" {
  vpc_id     = aws_vpc.Prod_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod_priv_sub2"
  }
}
#aws Prod public route table
resource "aws_route_table" "Prod_pub_route_table" {
  vpc_id = aws_vpc.Prod_vpc.id
  tags = {
  Name = "pub_route_table" }
}
#aws Prod private route table
resource "aws_route_table" "Prod_priv_route_table" {
  vpc_id = aws_vpc.Prod_vpc.id
  tags = {
    Name = "priv_route_table"
  }
}
#aws Prod route table association
resource "aws_route_table_association" "Prod_pub-route-table-association-1" {
  subnet_id      = aws_subnet.Prod_pub_sub1.id
  route_table_id = aws_route_table.Prod_pub_route_table.id
}
resource "aws_route_table_association" "Prod_pub-route-table-association-2" {
  subnet_id      = aws_subnet.Prod_pub_sub2.id
  route_table_id = aws_route_table.Prod_pub_route_table.id
}
#aws Prod route table association
resource "aws_route_table_association" "Prod-priv-route-table-association-1" {
  subnet_id      = aws_subnet.Prod_priv_sub1.id
  route_table_id = aws_route_table.Prod_priv_route_table.id
}
resource "aws_route_table_association" "Prod-priv-route-table-association-2" {
  subnet_id      = aws_subnet.Prod_priv_sub2.id
  route_table_id = aws_route_table.Prod_priv_route_table.id
}

# Prod_aws_internet_gateway
resource "aws_internet_gateway" "Prod_igw" {
  vpc_id = aws_vpc.Prod_vpc.id
  tags = {
    Name = "prod igw"
  }
}
#aws route for igw & public route table 
resource "aws_route" "Prob_pub_internet_igw" {
  route_table_id         = aws_route_table.Prod_pub_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Prod_igw.id
}

#elastic ip
resource "aws_eip" "prod_eip" {
  tags = {
    Name= "prod-eip"
  }
  
}
#nat gateway
resource "aws_nat_gateway" "prod-nat-gateway" {
  allocation_id = aws_eip.prod_eip.id
  subnet_id = aws_subnet.Prod_pub_sub1.id
}

# nat gateway routing
resource "aws_route" "private-route" {
  route_table_id = aws_route_table.Prod_priv_route_table.id
  gateway_id = aws_nat_gateway.prod-nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}
