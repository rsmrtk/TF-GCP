################################################################################
# Monitoring Dashboard
#
# Creates a Cloud Monitoring dashboard with a grid layout. Each widget in
# dashboard_widgets is rendered as an XY chart, scorecard, or text widget.
# The dashboard is only created when widgets are provided.
################################################################################

resource "google_monitoring_dashboard" "this" {
  count = length(var.dashboard_widgets) > 0 ? 1 : 0

  project        = var.project_id
  dashboard_json = jsonencode(local.dashboard_config)
}

locals {
  dashboard_config = {
    displayName = "${local.name_prefix}-dashboard"

    gridLayout = {
      columns = 2
      widgets = [
        for widget in var.dashboard_widgets : (
          widget.widget_type == "text" ? {
            title = widget.title
            text = {
              content = widget.text
              format  = "MARKDOWN"
            }
          } : widget.widget_type == "scorecard" ? {
            title = widget.title
            scorecard = {
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"${widget.metric_type}\""
                  aggregation = {
                    alignmentPeriod    = "300s"
                    perSeriesAligner   = "ALIGN_MEAN"
                    crossSeriesReducer = "REDUCE_MEAN"
                  }
                }
              }
            }
          } : {
            title = widget.title
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"${widget.metric_type}\""
                      aggregation = {
                        alignmentPeriod    = "300s"
                        perSeriesAligner   = "ALIGN_MEAN"
                        crossSeriesReducer = "REDUCE_MEAN"
                      }
                    }
                  }
                  plotType   = "LINE"
                  legendTemplate = widget.title
                },
              ]
              timeshiftDuration = "0s"
              yAxis = {
                scale = "LINEAR"
              }
            }
          }
        )
      ]
    }

  }
}
