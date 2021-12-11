output "instance-private-ip"{
    value = aws_instance.app_server.*.private_ip 
}

output "instance-public-ip"{
    value = aws_instance.app_server.*.public_ip
}

