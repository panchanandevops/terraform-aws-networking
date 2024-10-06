resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  
  for_each = {
    for key, subnet in var.subnet_settings : key => subnet
    if subnet.public_ip == true
  } 

  map_public_ip_on_launch = each.value.public_ip

  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone


  tags = {
    Name = "${var.env}-public-${each.key}"
  }
}