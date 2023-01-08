variable age {
    type =  number 
    
}



variable "username" {

    type = string
  
}

output "print" {

    value = "Hello my name is ${var.username}, your age is ${var.age}"
  
}
