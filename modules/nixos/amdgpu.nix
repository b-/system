{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };
  hardware.opengl.driSupport = true; # This is already enabled by default
  hardware.opengl.driSupport32Bit = true; # For 32 bit applications
  hardware.opengl.extraPackages = with pkgs; [ amdvlk ];
  # For 32 bit applications 
  hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
}
