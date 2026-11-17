{ ... }:

{
  # sudo con Touch ID (sudo_local sopravvive agli update di macOS)
  security.pam.services.sudo_local.touchIdAuth = true;
}
