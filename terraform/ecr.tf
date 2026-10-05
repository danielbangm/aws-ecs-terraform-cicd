resource "aws_ecr_repository" "frontend" {
  name                 = "devops-challenge-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "devops-challenge-frontend"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "devops-challenge-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "devops-challenge-backend"
  }
}