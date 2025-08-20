{ pkgs, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "stuart.alan.small@gmail.com";
  };
}
