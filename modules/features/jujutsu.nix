{
  features.jujutsu.homeManager =
    { config, ... }:
    {
      programs.jujutsu = {
        enable = true;
        settings.user = {
          inherit (config.programs.git.settings.user) name email;
        };
      };
    };
}
