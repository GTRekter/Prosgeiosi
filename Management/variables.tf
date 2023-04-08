variable "provider_settings" {
  type = object({
    subscription_id = string
    tenant_id       = string
  })
  description = "Provider settings"
}
variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Resource group settings"
}
variable "dashboards" {
  type = list(object({
    name          = string
    json_filename = string
    variables     = map(string)
  }))
  description = "List of dashboards to create"
}
variable "automation_account" {
    type = object({
        name     = string
        sku_name = string
        software_update_configurations = list(object({
            name                            = string
            operating_system                = string
            duration                        = string
            classification_included         = optional(string)
            classifications_included        = optional(list(string))
            excluded_packages               = optional(list(string))
            included_packages               = optional(list(string))
            excluded_knowledge_base_numbers = optional(list(string))
            included_knowledge_base_numbers = optional(list(string))
            reboot                          = string
        }))
        schedule = object({
            name = string
            description = optional(string)
            frequency = string # OneTime, Day, Hour, Week, or Month
            interval = number # Only valid when frequency is Day, Hour, Week, or Month
            start_time = string
            week_days = optional(list(string)) # Only valid when frequency is Week. Possible values are Monday, Tuesday, Wednesday, Thursday, Friday, Saturday and Sunday.
            month_days = optional(list(string)) # Must be between 1 and 31. -1 for last day of the month. Only valid when frequency is Month.
            monthly_occurrences = optional(list(object({ # Only valid when frequency is Month
                day        = string
                occurrence = number
            })))
        })
        source_control = object({
            name                =  string
            description         = optional(string)
            branch              = string
            repository_url      = string
            source_control_type = string
            folder_path         = string
            token_type          = string
            token               = string
        })
        dsc_configurations = list(object({
            name                      = string
            content_embedded_filename = string
        }))
    })
    description = "Automation account settings"
}
variable "log_analytics_workspace" {
  type = object({
    name     = string
    sku_name = string
  })
  description = "Log Analytics Workspace settings"
}