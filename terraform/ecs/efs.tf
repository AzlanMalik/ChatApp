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

/* --------------------- EFS ACCESS POINS FOR DB AND APP -------------------- */
resource "aws_efs_access_point" "efs-access-point-app" {
  file_system_id = aws_efs_file_system.efs-file-system.id
  posix_user {
    gid = 33 #gid of www-data apache user
    uid = 33 #uid of www-data apache user
    secondary_gids = [0]
  }
  root_directory {
    creation_info {
      owner_gid = 33
      owner_uid = 33
      permissions = "0775"
    }
    path = "/images"
  }
  tags = {
    Name = "${var.app-name}-${var.environment}-app-efs-accespoint"
  }
}

resource "aws_efs_access_point" "efs-access-point-db" {
 file_system_id = aws_efs_file_system.efs-file-system.id
  posix_user {
    gid = 999 #gid of mysql user
    uid = 999 #uid of mysql user
  }
  root_directory {
    creation_info {
      owner_gid = 999
      owner_uid = 999
      permissions = "0775"
    }
    path = "/db"
  }
  tags = {
    Name = "${var.app-name}-${var.environment}-db-efs-accespoint"
  }
}

/* ------------------------- SECURITY GROUP FOR EFS ------------------------- */
resource "aws_security_group" "my-efs-security-group" {
 name        = "${var.app-name}-efs-sg"
 description = "${var.app-name} ${var.environment} efs security group"
 vpc_id      = aws_vpc.my-vpc.id

 ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
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