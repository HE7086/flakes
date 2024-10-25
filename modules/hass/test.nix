{
  services.home-assistant.config = {
    shell_command = {
      test_command1 = "date >> /var/lib/hass/test.log";
    };
  };
}
