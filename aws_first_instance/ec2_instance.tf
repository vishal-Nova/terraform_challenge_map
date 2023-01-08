
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = path.module / id_rsa.pub
}





# resource "aws_instance" "web" {
#   ami           = "ami-0f69bc5520884278e"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "web-server"
#   }
# }
