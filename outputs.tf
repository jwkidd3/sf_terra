output "the_ip" {
  value = aws_instance.front-end.public_ip
}
