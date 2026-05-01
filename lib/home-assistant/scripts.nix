{
  enable_mood_lighting = {
    alias = "Enable Mood Lighting";
    sequence = [
      {
        service = "light.turn_off";
        metadata = { };
        data = { };
        target = {
          label_id = "big_light";
        };
      }
      {
        service = "light.turn_on";
        metadata = { };
        data = {
          transition = 3;
          brightness_pct = 25;
          rgb_color = [ 191 44 114 ];
        };
        target = {
          label_id = "small_light";
        };
      }
    ];
    mode = "single";
    icon = "mdi:saxophone";
  };

  turn_off_all_lights = {
    alias = "Turn Off All Lights";
    sequence = [
      {
        service = "light.turn_off";
        metadata = { };
        data = { };
        target = {
          label_id = [ "small_light" "big_light" ];
        };
      }
    ];
    mode = "single";
    icon = "mdi:alarm-light-off";
  };
}