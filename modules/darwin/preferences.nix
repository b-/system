{...}: {
  system.defaults = {
    # login window settings
    loginwindow = {
      # disable guest account
      GuestEnabled = false;
      # show name instead of username
      SHOWFULLNAME = false;
    };

    # file viewer settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = true;
      _FXShowPosixPathInTitle = true;
    };

    # trackpad settings
    trackpad = {
      # silent clicking = 0, default = 1
      ActuationStrength = 0;
      # disable tap to click
      Clicking = false;
      # firmness level, 0 = lightest, 2 = heaviest
      FirstClickThreshold = 2;
      # firmness level for force touch
      SecondClickThreshold = 2;
      # allow 2-finger right click
      TrackpadRightClick = true;
      # three finger drag for space switching
      # TrackpadThreeFingerDrag = true;
    };

    # firewall settings
    alf = {
      # 0 = disabled 1 = enabled 2 = blocks all connections except for essential services
      globalstate = 1;
      loggingenabled = 0;
      stealthenabled = 1;
    };

    # dock settings
    dock = {
      # auto show and hide dock
      autohide = false;
      # remove delay for showing dock
      #autohide-delay = 0.0;
      # how fast is the dock showing animation
      #autohide-time-modifier = 1.0;
      tilesize = 50;
      static-only = false;
      showhidden = false;
      show-recents = true;
      show-process-indicators = true;
      orientation = "bottom";
      mru-spaces = true;

      # top-left corner action
      wvous-tl-corner = 2; # * `1`: Disabled `2`: Mission Control `3`: Application Windows `4`: Desktop `5`: Start Screen Saver `6`: Disable Screen Saver `7`: Dashboard `10`: Put Display to Sleep `11`: Launchpad `12`: Notification Center `13`: Lock Screen `14`: Quick Note
    };

    NSGlobalDomain = {
      # allow key repeat
      ApplePressAndHoldEnabled = false;
      # delay before repeating keystrokes
      InitialKeyRepeat = 15;
      # delay between repeated keystrokes upon holding a key
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "WhenScrolling";
    };
  };

  system.keyboard = {
    enableKeyMapping = false; # because of karabiner
    remapCapsLockToControl = false; # because of karabiner
  };
}
