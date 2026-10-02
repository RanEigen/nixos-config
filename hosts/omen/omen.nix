# EC 解锁与风扇曲线仅适用于已核验机型（REF:2026-08-23-omen-ec）。
{ config, inputs, ... }:
{
  imports = [ inputs.omen-rs.nixosModules.default ];
  assertions = [
    {
      assertion = config.networking.hostName == "omen";
      message = "OMEN EC 策略不能用于其他机器；请移除 hosts/omen/omen.nix 并核验目标硬件。";
    }
  ];
  services.omen = {
    enable = true;
    performance = "performance";
    holdInterval = 30;
    batteryCare = true;
    logLevel = "info";
    fanCurve = [
      {
        temp = 35;
        speed = 10;
      }
      {
        temp = 45;
        speed = 15;
      }
      {
        temp = 50;
        speed = 20;
      }
      {
        temp = 60;
        speed = 28;
      }
      {
        temp = 70;
        speed = 32;
      }
      {
        temp = 78;
        speed = 40;
      }
      {
        temp = 85;
        speed = 64;
      }
    ];
  };
}
