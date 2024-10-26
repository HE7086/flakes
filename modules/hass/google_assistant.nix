{
  services.home-assistant.config.google_assistant = {
    project_id = "!secret project_id";
    service_account = "!include SERVICE_ACCOUNT.JSON";
    report_state = true;
    exposed_domains = [
      "button"
      "event"
      "group"
      "input_boolean"
      "input_button"
      "input_select"
      "scene"
      "script"
      "select"
      "switch"
    ];
    entity_config = {};
  };
}
