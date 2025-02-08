resource "aws_dynamodb_table" "table" {
  name         = "${var.name}_dynamodb_metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "created_at"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  attribute {
    name = "record_type"
    type = "S"
  }

  global_secondary_index {
    name            = "record_type-index"
    hash_key        = "record_type"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "record_type_created_at-index"
    hash_key        = "record_type"
    range_key       = "created_at"
    projection_type = "ALL"
  }
}
