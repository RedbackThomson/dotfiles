[
  {
    id = "1699834548960";
    alias = "Turn light on after sunset";
    description = "";
    triggers = [
      {
        device_id = "2e8d17cc67bda232b18b6c5a4813d12c";
        domain = "device_tracker";
        entity_id = "f9e63207a711f274be0ef8665bb79a58";
        type = "enters";
        zone = "zone.home";
        trigger = "device";
      }
      {
        device_id = "df0324697c552cf811c5acd4a0eaf34d";
        domain = "device_tracker";
        entity_id = "a501777b7c94841f4c09158fff44b783";
        type = "enters";
        trigger = "device";
        zone = "zone.home";
      }
    ];
    conditions = [
      {
        condition = "sun";
        after = "sunset";
      }
    ];
    actions = [
      {
        type = "turn_on";
        device_id = "424175914b7a2868d4243b2179bbb42d";
        entity_id = "93ff05e238b5ad39c3b910264c39f638";
        domain = "switch";
      }
    ];
    mode = "single";
  }

  {
    id = "1700003094048";
    alias = "Notify when iPad below 30%";
    description = "";
    trigger = [
      {
        platform = "numeric_state";
        entity_id = [ "sensor.nicholass_ipad_battery_level" ];
        below = 30;
      }
    ];
    condition = [ ];
    action = [
      {
        device_id = "2e8d17cc67bda232b18b6c5a4813d12c";
        domain = "mobile_app";
        type = "notify";
        message = "iPad dropped below 30% charge";
        title = "iPad battery low";
      }
    ];
    mode = "single";
  }

  {
    id = "1720370654902";
    alias = "Royals Vote Timer";
    description = "";
    trigger = [
      {
        platform = "time";
        at = "19:15:00";
      }
    ];
    condition = [ ];
    action = [
      {
        service = "notify.mobile_app_nicholass_iphone";
        metadata = { };
        data = {
          message = "Time to vote!";
          title = "Royals Vote";
          data = {
            actions = [
              {
                action = "URI";
                title = "Open Royals";
                uri = "https://royals.ms/vote";
              }
            ];
          };
        };
      }
    ];
    mode = "single";
  }

  {
    id = "1752339952034";
    alias = "Gym Morning Wakeup";
    description = "";
    triggers = [
      {
        at = "input_datetime.gym_time";
        trigger = "time";
      }
    ];
    conditions = [
      {
        condition = "state";
        entity_id = "input_boolean.gym_morning";
        state = "on";
      }
    ];
    actions = [
      {
        action = "light.turn_on";
        metadata = { };
        data = {
          transition = 60;
          brightness_pct = 20;
        };
        target = {
          area_id = "bedroom";
        };
      }
      {
        action = "cover.set_cover_position";
        metadata = { };
        data = {
          position = 80;
        };
        target = {
          device_id = "2514666b3f031df88cc7f0697dd9eb22";
        };
      }
      {
        action = "input_boolean.turn_off";
        metadata = { };
        data = { };
        target = {
          entity_id = "input_boolean.gym_morning";
        };
      }
    ];
    mode = "single";
  }

  {
    id = "1753065225518";
    alias = "Zigbee Button Pressed";
    description = "";
    triggers = [
      {
        device_id = "4953d50309c309d881927e40a954e3f0";
        domain = "zha";
        type = "remote_button_short_press";
        subtype = "button_1";
        trigger = "device";
      }
    ];
    conditions = [ ];
    actions = [
      {
        action = "light.toggle";
        metadata = { };
        data = { };
        target = {
          area_id = "living_room";
        };
      }
    ];
    mode = "single";
  }

  {
    id = "1753397811842";
    alias = "Office light button";
    description = "";
    triggers = [
      {
        device_id = "4953d50309c309d881927e40a954e3f0";
        domain = "zha";
        type = "remote_button_double_press";
        subtype = "button_1";
        trigger = "device";
      }
    ];
    conditions = [ ];
    actions = [
      {
        action = "light.toggle";
        metadata = { };
        data = { };
        target = {
          area_id = "office";
        };
      }
    ];
    mode = "single";
  }

  {
    id = "1753485873182";
    alias = "Office Light Switch On";
    description = "";
    triggers = [
      {
        type = "turned_on";
        device_id = "89383221edb35f954083450290ed578e";
        entity_id = "e67d030353781f7f58d4a22d569d8d75";
        domain = "switch";
        trigger = "device";
      }
    ];
    conditions = [ ];
    actions = [
      {
        action = "light.turn_on";
        metadata = { };
        data = { };
        target = {
          area_id = "office";
        };
      }
    ];
    mode = "single";
  }

  {
    id = "1753485952889";
    alias = "Office Light Switch Off";
    description = "";
    triggers = [
      {
        type = "turned_off";
        device_id = "89383221edb35f954083450290ed578e";
        entity_id = "e67d030353781f7f58d4a22d569d8d75";
        domain = "switch";
        trigger = "device";
      }
    ];
    conditions = [ ];
    actions = [
      {
        action = "light.turn_off";
        metadata = { };
        data = { };
        target = {
          area_id = "office";
        };
      }
    ];
    mode = "single";
  }

  {
    id = "1753835367355";
    alias = "Bedroom Light Switch Off";
    description = "";
    triggers = [
      {
        type = "turned_off";
        device_id = "9b2204d8627b57be00457668e8faadd5";
        entity_id = "e1990d5ba594af22ab4993d852549014";
        domain = "switch";
        trigger = "device";
      }
    ];
    conditions = [ ];
    actions = [
      {
        action = "light.turn_off";
        metadata = { };
        data = { };
        target = {
          area_id = "bedroom";
        };
      }
    ];
    mode = "single";
  }

  {
    id = "1753835424337";
    alias = "Bedroom Light Switch On";
    description = "";
    triggers = [
      {
        type = "turned_on";
        device_id = "9b2204d8627b57be00457668e8faadd5";
        entity_id = "e1990d5ba594af22ab4993d852549014";
        domain = "switch";
        trigger = "device";
      }
    ];
    conditions = [ ];
    actions = [
      {
        action = "light.turn_on";
        metadata = { };
        data = {
          brightness_pct = 20;
        };
        target = {
          area_id = "bedroom";
        };
      }
    ];
    mode = "single";
  }
]