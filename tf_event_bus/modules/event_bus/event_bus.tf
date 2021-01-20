resource "aws_cloudwatch_event_bus" "tf_main_event_bus" {
  name = "tf-main-event-bus-${terraform.workspace}"
}
