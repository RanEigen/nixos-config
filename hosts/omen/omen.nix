# EC 解锁与风扇曲线仅适用于已核验机型（REF:2026-08-23-omen-ec）。
{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.omen-rs.nixosModules.default ];
  # 当前 acpi_call 手动复制 .ko，跳过了新内核的 kmodigest 签名。
  # 为所有内核补齐单模块证书；上游安装流程修复后删除此兼容项。
  nixpkgs.overlays = [
    (final: prev: {
      kernelPackagesExtensions = prev.kernelPackagesExtensions ++ [
        (kernelFinal: kernelPrev: {
          acpi_call = kernelPrev.acpi_call.overrideAttrs (old: {
            # 必须在 strip 等 fixup 完成后签名，避免签名后的模块内容再次变化。
            postFixup = (old.postFixup or "") + ''
              module="$out/lib/modules/${kernelFinal.kernel.modDirVersion}/misc/acpi_call.ko"
              if [ ! -e "$module.cer" ]; then
                ${lib.getExe final.buildPackages.kmodigest} "$module"
              fi
            '';
          });
        })
      ];
    })
  ];
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
