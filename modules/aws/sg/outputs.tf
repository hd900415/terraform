# 保持向后兼容的现有输出
output "security_group_ids" {
  value = [aws_security_group.web.id, aws_security_group.Allow-from-office.id]
}

# 为不同实例类型提供专门的安全组组合
output "web_security_group_ids" {
  description = "Security group IDs for web instances"
  value = [
    aws_security_group.web.id,
    aws_security_group.Allow-from-office.id
  ]
}

output "test_security_group_ids" {
  description = "Security group IDs for test instances"
  value = [
    aws_security_group.test.id,
    aws_security_group.Allow-from-office.id  # 保持 SSH 访问能力
  ]
}

# 提供灵活的映射结构（推荐方案）
output "security_groups_by_type" {
  description = "Map of security groups by instance type"
  value = {
    web = [
      aws_security_group.web.id,
      aws_security_group.Allow-from-office.id
    ]
    test = [
      aws_security_group.test.id,
      aws_security_group.Allow-from-office.id
    ]
    whitelist = [
      aws_security_group.web.id,
      aws_security_group.whitelist.id,
      aws_security_group.Allow-from-office.id
    ]
  }
}

# 单独的安全组 ID 输出（便于其他模块引用）
output "web_sg_id" {
  value = aws_security_group.web.id
}

output "test_sg_id" {
  value = aws_security_group.test.id
}

output "office_sg_id" {
  value = aws_security_group.Allow-from-office.id
}

output "whitelist_sg_id" {
  value = aws_security_group.whitelist.id
  
}
