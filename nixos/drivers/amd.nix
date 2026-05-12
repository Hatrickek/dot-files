{ config, pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "amdgpu" ];
  boot.extraModprobeConfig = "options amdgpu ppfeaturemask=0xffffffff\n";  # amdgpu overdrive
  # boot.kernelParams = [
  #   "video=DP-1:3840x2160@240"
  #   "video=DP-2:1920x1080@75"
  # ];
  hardware.amdgpu = {
    overdrive.enable = true;
    opencl.enable = true;
  };
}

