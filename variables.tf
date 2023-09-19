# VARIABLE TYPES:
# variable "foo" {
#  description = "Foo example variable."
#  type = string
# }
# variable "foo_list" {
#  description = "Foo list example."
#  type    = list(string)
# }
# variable "foo_object" {
#  description = "Foo complex type example."
#  type = map(object({
#    eggs = string
#  }))
#  default = {
#    foo_key = { eggs = "eggs value" }
#  }
# }

variable "bucket_location" {
  description = "Bucket location"
  type = string
  default = "US"
}


