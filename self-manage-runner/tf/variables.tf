# create variable named "project_name" in type string
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "gitlab-runner"
}

# create variable named "instance_type" in type string
variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "runner_token" {
  description = "The token of gitlab runner runner"
  type        = string
}


variable "runner_name" {
  description = "The name of gitlab runner"
  type        = string
}

variable "runner_executor" {
  description = "The executor of gitlab runner"
  type        = string
  default     = "shell"
}

variable "runner_server" {
  description = "The server of gitlab runner"
  type        = string
  default     = "https://gitlab.com/"
}

variable "runner_tags" {
  description = "The tags of gitlab runner"
  type        = list(string)
  default     = []
}

