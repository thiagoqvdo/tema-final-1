variable "tag" {
    type = string
    default = "latest"
}

variable "dockerhub_username" {
    type = string 
    default = ""
}

variable "dockerhub_password" {
    type = string 
    default = ""
}

source "docker" "basic-email-sharer" {
    image = "williamyeh/ansible:ubuntu18.04"
    commit = true
        changes = [
            "ENTRYPOINT java -jar /home/app/basic-email-sharer-${var.tag}.jar"
        ]
}

build {
    sources = ["source.docker.basic-email-sharer"]

    provisioner "ansible-local" {
        playbook_file = "./job2/playbook.yaml"
    }
    provisioner "shell" {
        inline = ["mkdir /home/app"] 
    }
    provisioner "file" {
        source = "./basic-email-sharer-${var.tag}.jar"
        destination = "/home/app/basic-email-sharer-${var.tag}.jar"
    }

    post-processors {
        post-processor "docker-tag" {
            repository = "qvdo/basic-email-sharer"
            tags = ["${var.tag}"]
        }
        post-processor "docker-push" {
            login = true
            login_username = "${var.dockerhub_username}"
            login_password = "${var.dockerhub_password}"
        }
    }
    
}