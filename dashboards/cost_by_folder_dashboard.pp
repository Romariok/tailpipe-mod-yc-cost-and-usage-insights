dashboard "yc_billing_log_cost_by_folder" {
  title = "Yandex Cloud: Cost by Folder"

  container {
    input "cloud_billing_report_cost_by_folder_dashboard_folders" {
      title       = "Select folder(s):"
      description = "Choose one or more YC folders to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cloud_billing_report_cost_by_folder_dashboard_folders_input
    }
  }

  container {
    card "yc_billing_log_cost_by_folder_total" {
      title = "Cost by service (total)"
      query = query.yc_billing_log_cost_by_folder_total
      width = 3
      args = {
        "folder_ids" = self.input.cloud_billing_report_cost_by_folder_dashboard_folders.value
      }
    }
  }

  container {   
    chart "yc_billing_log_cost_by_folder_bar" {
      title = "Cost by service"
      type  = "bar"
      query = query.yc_billing_log_cost_and_labels_by_folder_total
      width = 6
      args = {
        "folder_ids" = self.input.cloud_billing_report_cost_by_folder_dashboard_folders.value
      }
    }

    chart "yc_billing_log_cost_by_folder_pie" {
      title = "Cost by service"
      type  = "pie"
      query = query.yc_billing_log_cost_and_labels_by_folder_total
      width = 6
      args = {
        "folder_ids" = self.input.cloud_billing_report_cost_by_folder_dashboard_folders.value
      }
    }
  }
}

query "yc_billing_log_cost_and_labels_by_folder_total" {
  sql = <<-EOQ
    SELECT
      folder_name AS folder,
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS cost
    FROM yc_billing_log
    WHERE ('all' in ($1) or folder_id in $1)
    GROUP BY 1
    ORDER BY cost DESC;
  EOQ

  param "folder_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "yc_billing_log_cost_by_folder_total" {
  sql = <<-EOQ
    SELECT
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS cost
    FROM yc_billing_log
    WHERE ('all' in ($1) or folder_id in $1)
    ORDER BY cost DESC;
  EOQ

  param "folder_ids" {}

  tags = {
    folder = "Hidden"
  }
}


query "cloud_billing_report_cost_by_folder_dashboard_folders_input" {
  sql = <<-EOQ
    with folder_ids as (
      select
        distinct on(folder_id)
        folder_id || ' (' || coalesce(folder_name, '') || ')' as label,
        folder_id as value
      from
        yc_billing_log
      where
        folder_id is not null and folder_id != ''
        and folder_name is not null and folder_name != ''
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
      folder_ids;
  EOQ

  tags = {
    folder = "Hidden"
  }
}

