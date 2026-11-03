# 用户目录与默认应用。
{ my, ... }:
{
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      inherit (my.desktop.userDirectories)
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
      defaultApplications = my.desktop.defaultApplications;
    };
  };
}
