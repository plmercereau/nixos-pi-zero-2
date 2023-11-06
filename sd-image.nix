# This module extends the official sd-image.nix with the following:
# - ability to add options to the config.txt firmware
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.sdImage = with lib; {
    extraFirmwareConfig = mkOption {
      type = types.attrs;
      default = {};
      description = lib.mdDoc ''
        Extra configuration to be added to config.txt.
      '';
    };
  };

  config = {
    sdImage.populateFirmwareCommands =
      lib.mkIf ((lib.length (lib.attrValues config.sdImage.extraFirmwareConfig)) > 0)
      (
        let
          # Convert the set into a string of lines of "key=value" pairs.
          keyValueMap = name: value: name + "=" + toString value;
          keyValueList = lib.mapAttrsToList keyValueMap config.sdImage.extraFirmwareConfig;
          extraFirmwareConfigString = lib.concatStringsSep "\n" keyValueList;
        in
          lib.mkAfter
          ''
            config=firmware/config.txt
            # The initial file has just been created without write permissions. Add them to be able to append the file.
            chmod u+w $config
            echo "\n# Extra configuration" >> $config
            echo "${extraFirmwareConfigString}" >> $config
            chmod u-w $config
          ''
      );
  };
}
