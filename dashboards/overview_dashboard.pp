dashboard "yc_overview" {
  title = "Yandex Cloud: Overview"

  container {
    card "total_cost_all_time" {
      title = "Total cost (all time)"
      query = query.yc_total_cost_overall
      width = 6
    }


    chart "ovw_cost_by_day_line" {
      title = "Cost by day"
      type  = "line"
      query = query.yc_cost_by_day
      width = 6
    }
  }

  container {

    chart "ovw_cost_by_service_bar" {
      title = "Cost by service (bar)"
      type  = "bar"
      query = query.yc_cost_by_service
      width = 6
    }

    chart "ovw_cost_by_folder_bar" {
      title = "Cost by folder (bar)"
      type  = "bar"
      query = query.yc_cost_by_folder
      width = 6
    }
  }
}

query "yc_total_cost_overall" {
  sql = <<-EOQ
    SELECT
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS total_cost
    FROM yc_billing_log;
  EOQ

  tags = {
    folder = "Hidden"
  }
}

query "yc_cost_by_day" {
  sql = <<-EOQ
    SELECT
      CAST(date AS DATE) AS day,
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS cost
    FROM yc_billing_log
    GROUP BY 1
    ORDER BY 1;
  EOQ

  tags = {
    folder = "Hidden"
  }
}

query "yc_cost_by_service" {
  sql = <<-EOQ
    SELECT
      service_name AS service,
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS cost
    FROM yc_billing_log
    GROUP BY 1
    ORDER BY cost DESC
    LIMIT 20;
  EOQ

  tags = {
    folder = "Hidden"
  }
}

query "yc_cost_by_folder" {
  sql = <<-EOQ
    SELECT
      COALESCE(NULLIF(folder_name,''), folder_id) AS folder,
      ROUND(SUM(COALESCE(cost,0)
        - COALESCE(credit,0)
      ), 2) AS cost
    FROM yc_billing_log
    GROUP BY 1
    ORDER BY cost DESC
    LIMIT 20;
  EOQ
}


