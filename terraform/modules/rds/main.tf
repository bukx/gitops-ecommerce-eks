###############################################################################
# RDS PostgreSQL Module — Multi-AZ with automated backups
###############################################################################

variable "identifier"          { type = string }
variable "engine_version"      { type = string; default = "15.4" }
variable "instance_class"      { type = string; default = "db.r6g.large" }
variable "allocated_storage"   { type = number; default = 100 }
variable "multi_az"            { type = bool; default = true }
variable "vpc_id"              { type = string }
variable "subnet_ids"          { type = list(string) }
variable "allowed_cidr_blocks" { type = list(string); default = [] }
variable "backup_retention"    { type = number; default = 7 }
variable "deletion_protection" { type = bool; default = true }
variable "tags"                { type = map(string); default = {} }

resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.identifier}-rds-"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.identifier}-rds-sg" })
}

resource "aws_db_instance" "main" {
  identifier              = var.identifier
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.allocated_storage * 2
  storage_encrypted       = true
  multi_az                = var.multi_az
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_name                 = "app"
  username                = "dbadmin"
  manage_master_user_password = true
  backup_retention_period = var.backup_retention
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.identifier}-final"
  performance_insights_enabled = true
  monitoring_interval     = 60
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  tags = var.tags
}

output "endpoint" { value = aws_db_instance.main.endpoint }
output "arn"      { value = aws_db_instance.main.arn }
output "id"       { value = aws_db_instance.main.id }
