resource "aws_ecr_repository" "indices_economicos" {
  name                 = format("%s/indices-economicos", var.project_name)
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "indices_combustiveis" {
  name                 = format("%s/indices-combustiveis", var.project_name)
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}