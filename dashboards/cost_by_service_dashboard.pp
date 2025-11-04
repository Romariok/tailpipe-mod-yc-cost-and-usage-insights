dashboard "yc_billing_log_cost_by_service" {
  title = "Yandex Cloud: Cost by Service"

  container {
    input "cloud_billing_report_cost_by_service_dashboard_services" {
      title       = "Select service(s):"
      description = "Choose one or more YC services to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cloud_billing_report_cost_by_service_dashboard_services_input
    }
  }

  container {
    card "yc_billing_log_cost_by_service_total" {
      title = "Cost by service (total)"
      query = query.yc_billing_log_cost_by_service_total
      width = 3
      args = {
        "service_ids" = self.input.cloud_billing_report_cost_by_service_dashboard_services.value
      }
    }
  }

  container {   
    chart "yc_billing_log_cost_by_service_bar" {
      title = "Cost by service"
      type  = "bar"
      query = query.yc_billing_log_cost_and_labels_by_service_total
      width = 6
      args = {
        "service_ids" = self.input.cloud_billing_report_cost_by_service_dashboard_services.value
      }
    }

    chart "yc_billing_log_cost_by_service_pie" {
      title = "Cost by service"
      type  = "pie"
      query = query.yc_billing_log_cost_and_labels_by_service_total
      width = 6
      args = {
        "service_ids" = self.input.cloud_billing_report_cost_by_service_dashboard_services.value
      }
    }
  }
}

query "yc_billing_log_cost_and_labels_by_service_total" {
  sql = <<-EOQ
    SELECT
      service_name AS service,
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS cost
    FROM yc_billing_log
    WHERE ('all' in ($1) or service_id in $1)
    GROUP BY 1
    ORDER BY cost DESC;
  EOQ

  param "service_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "yc_billing_log_cost_by_service_total" {
  sql = <<-EOQ
    SELECT
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS cost
    FROM yc_billing_log
    WHERE ('all' in ($1) or service_id in $1)
    ORDER BY cost DESC;
  EOQ

  param "service_ids" {}

  tags = {
    folder = "Hidden"
  }
}


query "cloud_billing_report_cost_by_service_dashboard_services_input" {
  sql = <<-EOQ
    with service_ids as (
      select
        distinct on(service_id)
        service_id || ' (' || coalesce(service_name, '') || ')' as label,
        service_id as value
      from
        yc_billing_log
      where
        service_id is not null and service_id != ''
        and service_name is not null and service_name != ''
      order by label
    )
    select
      'All' as label,
      'all' as value
    union all
    select
      label,
      value
    from
      service_ids;
  EOQ

  tags = {
    folder = "Hidden"
  }
}

