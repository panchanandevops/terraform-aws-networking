resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


# Assuming each value is a subnet object with an 'id' attribute
resource "aws_route_table_association" "public_rt_association" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id  
  route_table_id = aws_route_table.public_rt.id
}
