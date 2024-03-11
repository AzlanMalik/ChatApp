/* -------------------------------------------------------------------------- */
/*                               EFS FILE SYSTEM                              */
/* -------------------------------------------------------------------------- */
resource "aws_efs_file_system" "efs-file-system" {
  creation_token = "${var.app-name}-${var.environment}-efs"
  encrypted = true

  tags = {
    Name = "${var.app-name}-${var.environment}-efs"
  }
}

/* ---------------------- EFS MOUNT TARGETS IN TWO AZ's --------------------- */
resource "aws_efs_mount_target" "efs-mount-target1" {
  file_system_id = aws_efs_file_system.efs-file-system.id
  subnet_id      = aws_subnet.public-subnet[0].id
  security_groups = [
    aws_security_group.my-efs-security-group.id
  ]
}

resource "aws_efs_mount_target" "efs-mount-target2" {
  file_system_id = aws_efs_file_system.efs-file-system.id
  subnet_id      = aws_subnet.public-subnet[1].id
  security_groups = [
    aws_security_group.my-efs-security-group.id
  ]
}

/* ------------------------- SECURITY GROUP FOR EFS ------------------------- */
resource "aws_security_group" "my-efs-security-group" {
 name        = "${var.app-name}-efs-sg"
 description = "${var.app-name} ${var.environment} efs security group"
 vpc_id      = aws_vpc.my-vpc.id


ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
    Name = "${var.app-name}-efs-sg"
 }
}