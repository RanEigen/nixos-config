# 用户目录与默认应用。
{ userConfig, ... }:
{
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      inherit (userConfig.preferences.desktop.userDirectories)
        desktop
        documents
        download
        music
        pictures
        publicShare
        templates
        videos
        ;
    };
    mimeApps = {
      enable = true;
      defaultApplications = userConfig.preferences.desktop.defaultApplications;
    };
  };
}
